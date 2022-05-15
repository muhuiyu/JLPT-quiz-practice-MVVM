//
//  FirebaseDataSource.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import Foundation
import Firebase

public enum VoidResult {
    case success
    case failure(Error)
}

class FirebaseDataSource: NSObject {
    static let shared = FirebaseDataSource()
    
    struct AttibuteKey {
        static let userID = "userID"
        static let quizID = "quizID"
        static let email = "email"
        static let name = "name"
        static let profilePhotoURL = "profilePhotoURL"
        static let age = "age"
        static let streakDays = "streakDays"
        static let numberOfAnsweredQuestions = "numberOfAnsweredQuestions"
        static let type = "type"
        static let level = "level"
        static let numberOfAttempts = "numberOfAttempts"
        static let numberOfSuccess = "numberOfSuccess"
        static let isMastered = "isMastered"
    }
    
    struct Constants {
        static let maximumNumberOfFetchRequest = 10
    }
    
    enum FirebaseError: Error {
        case snapshotMissing
        case multipleDocumentUsingSameID
        case dataKeyMissing
        case entryInitFailure
        case userMissing
        case documentMissing
        case invalidDocumentID
    }
}
// MARK: - User
extension FirebaseDataSource {
    func getUserProfileImage() -> URL? {
        guard let user = Auth.auth().currentUser else { return nil }
        return user.photoURL
    }
    private func fetchUserStats(completion: @escaping (Result<UserStats, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else { return completion(.failure(FirebaseError.userMissing)) }
        let ref = Firestore.firestore().collection(UserStats.collectionName)
        
        ref.whereField(AttibuteKey.userID, isEqualTo: user.uid).getDocuments { snapshot, error in
            if let error = error {
                return completion(.failure(error))
            }
            guard let snapshot = snapshot else { return completion(.failure(FirebaseError.snapshotMissing)) }
            if snapshot.documentChanges.count != 1 { return completion(.failure(FirebaseError.snapshotMissing)) }

            do {
                let entry = try UserStats(snapshot: snapshot.documentChanges[0].document)
                return completion(.success(entry))
            } catch {
                return completion(.failure(FirebaseError.entryInitFailure))
            }
        }
    }
}

// MARK: - Fetch items by IDs
protocol FirebaseFetchable: Decodable {
    static var collectionName: String { get }
}
extension FirebaseDataSource {
    func fetch<T: FirebaseFetchable>(_ type: T.Type, for id: String?, completion: @escaping (Result<T, Error>) -> Void) {
        guard let id = id else { return completion(.failure(FirebaseError.invalidDocumentID)) }
        let ref = Firestore.firestore().collection(type.collectionName).document(id)
        ref.getDocument(as: T.self) { result in
            switch result {
            case .success(let entry):
                return completion(.success(entry))
            case .failure(let error):
                return completion(.failure(error))
            }
        }
    }
    func fetchEntry(as type: QuizType, for id: String?, completion: @escaping(Result<Entry, Error>) -> Void) {
        func resultHandler<Success: Entry>(_ result: Result<Success, Error>) {
            switch result {
            case .failure(let error):
                return completion(.failure(error))
            case .success(let item):
                return completion(.success(item))
            }
        }
        switch type {
        case .grammar:
            fetch(Grammar.self, for: id, completion: resultHandler)
        case .kanji:
            fetch(Kanji.self, for: id, completion: resultHandler)
        case .vocab:
            fetch(Vocab.self, for: id, completion: resultHandler)
        default:
            break
        }
    }
}

// MARK: - Generate Quiz set
extension FirebaseDataSource {
    /// Fetch all quizzes based on user query (level and type)
    private func fetchQuizIDs(with configuration: QuizConfig, completion: @escaping (Result<[String], Error>) -> Void) {
        var ref: Query = Firestore.firestore().collection(Quiz.collectionName)
        
        if configuration.level != .all { ref = ref.whereField(AttibuteKey.level, isEqualTo: configuration.level.rawValue) }
        if configuration.type != .mixed { ref = ref.whereField(AttibuteKey.type, isEqualTo: configuration.type.rawValue) }
        
        ref.getDocuments { snapshot, error in
            if let error = error { return completion(.failure(error)) }
            guard let snapshot = snapshot else { return completion(.failure(FirebaseError.snapshotMissing)) }
            
            let quizIDs: [String] = snapshot
                .documentChanges
                .filter { $0.type == .added }
                .map { $0.document.documentID }
            
            return completion(.success(quizIDs))
        }
    }
    /// Fetch past question result (question answered, question mastered) of current user based on user query
    private func fetchPastQuestionResult(with configuration: QuizConfig, callback: @escaping (_ answeredQuizIDs: [String], _ skippedQuizIDs: [String], _ error: Error?) -> Void) {
        guard let user = Auth.auth().currentUser else { return callback([], [], FirebaseError.userMissing) }
        var ref = Firestore.firestore().collection(QuestionAttemptRecord.collectionName).whereField(AttibuteKey.userID, isEqualTo: user.uid)

        if configuration.level != .all { ref = ref.whereField(AttibuteKey.level, isEqualTo: configuration.level.rawValue) }
        if configuration.type != .mixed { ref = ref.whereField(AttibuteKey.type, isEqualTo: configuration.type.rawValue) }
        
        ref.getDocuments { snapshot, error in
            if let error = error { return callback([], [], error) }
            guard let snapshot = snapshot else { return callback([], [], FirebaseError.snapshotMissing) }
            if snapshot.documentChanges.isEmpty { return callback([], [], nil) }

            var questionStatsRawData: [QuestionAttemptRecord] = snapshot.documentChanges
                .filter { $0.type == .added }
                .compactMap { try? QuestionAttemptRecord(snapshot: $0.document) }
            
            // 50% possilibity to return quizzes which user answered wrongly
            if arc4random_uniform(100) < 50 {
                questionStatsRawData.sort()
            } else {
                questionStatsRawData.shuffle()
            }
            
            var answeredQuizIDs = [String]()
            var skipQuizIDs = [String]()
            for stat in questionStatsRawData {
                if stat.isMastered {
                    skipQuizIDs.append(stat.quizID)
                } else {
                    answeredQuizIDs.append(stat.quizID)
                }
            }
            return callback(answeredQuizIDs, skipQuizIDs, nil)
        }
    }
    private func selectQuizIdToSet(_ answeredQuizIDs: [String], _ skippedQuizIDs: [String], _ allQuizIDs: [String], select numberOfQuestions: Int) -> [String] {
        var selectedIDs = [String]()
        var currentIndexOfAnsweredQuizIDs = 0
        
        // add answered questions to the list (half at most)
        while currentIndexOfAnsweredQuizIDs < answeredQuizIDs.count {
            if selectedIDs.count >= numberOfQuestions / 2 { break }
            selectedIDs.append(answeredQuizIDs[currentIndexOfAnsweredQuizIDs])
            currentIndexOfAnsweredQuizIDs += 1
        }
        
        // add new questions to the list
        for id in allQuizIDs.shuffled() {
            if selectedIDs.count == numberOfQuestions { break }
            guard !answeredQuizIDs.contains(id), !skippedQuizIDs.contains(id) else { continue }
            selectedIDs.append(id)
        }
        
        while selectedIDs.count < numberOfQuestions && currentIndexOfAnsweredQuizIDs < answeredQuizIDs.count {
            selectedIDs.append(answeredQuizIDs[currentIndexOfAnsweredQuizIDs])
            currentIndexOfAnsweredQuizIDs += 1
        }
        
        return selectedIDs
    }
    /// generate question set based on user'past success rate on each question
    func generateQuizList(with configuration: QuizConfig, completion: @escaping (Result<[Quiz.ID], Error>) -> Void) {
        
        var answeredQuizIDs = [String]()
        var skippedQuizIDs = [String]()
        var allQuizIDs = [String]()
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        fetchPastQuestionResult(with: configuration) { answered, skipped, error in
            if let error = error { return completion(.failure(error)) }
            answeredQuizIDs = answered
            skippedQuizIDs = skipped
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchQuizIDs(with: configuration) { result in
            switch result {
            case .success(let all):
                allQuizIDs = all
            case .failure(let error):
                return completion(.failure(error))
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            let selectedIDs = self.selectQuizIdToSet(answeredQuizIDs, skippedQuizIDs, allQuizIDs, select: configuration.numberOfQuestions)
            return completion(.success(selectedIDs.shuffled()))
        }
    }
}
// MARK: - Update User Question Stats
extension FirebaseDataSource {
    /// Update question attempt record after user answered the question
    func updateQuestionAttemptRecord(for quizID: String, answer isCorrect: Bool, completion: @escaping (VoidResult) -> Void) {
        guard let user = Auth.auth().currentUser else { return completion(.failure(FirebaseError.userMissing)) }
        let collectionRef = Firestore.firestore().collection(QuestionAttemptRecord.collectionName)
        
        collectionRef.whereField(AttibuteKey.userID, isEqualTo: user.uid).whereField(AttibuteKey.quizID, isEqualTo: quizID).getDocuments { snapshot, error in
            if let error = error { return completion(.failure(error)) }
            guard let changes = snapshot?.documentChanges else { return completion(.failure(FirebaseError.snapshotMissing)) }
            
            if changes.isEmpty {
                _ = collectionRef.addDocument(from: QuestionAttemptRecord(quizID: quizID, userID: user.uid, answer: isCorrect))
                return completion(.success)
                
            } else if changes.count == 1 {
                let documentRef = collectionRef.document(changes[0].document.documentID)
                do {
                    let stats = try QuestionAttemptRecord(snapshot: changes[0].document)
                    let data = [
                        AttibuteKey.numberOfAttempts: stats.numberOfAttempts + 1,
                        AttibuteKey.numberOfSuccess: isCorrect ? stats.numberOfSuccess + 1 : stats.numberOfSuccess
                    ]
                    documentRef.updateData(data) { error in
                        if let error = error { return completion(.failure(error)) }
                        return completion(.success)
                    }
                } catch {
                    return completion(.failure(FirebaseError.entryInitFailure))
                }
            }
        }
    }
    /// Update question attempt record after user answered the question
    func markQuestionAsMastered(for quizID: String, completion: @escaping (VoidResult) -> Void) {
        guard let user = Auth.auth().currentUser else { return completion(.failure(FirebaseError.userMissing)) }
        let collectionRef = Firestore.firestore().collection(QuestionAttemptRecord.collectionName)
        collectionRef.whereField(AttibuteKey.userID, isEqualTo: user.uid).whereField(AttibuteKey.quizID, isEqualTo: quizID).getDocuments { snapshot, error in
            if let error = error { return completion(.failure(error)) }
            guard let changes = snapshot?.documentChanges, changes.count == 1 else {
                return completion(.failure(FirebaseError.snapshotMissing))
            }
            collectionRef.document(changes[0].document.documentID).updateData([AttibuteKey.isMastered: true]) { error in
                if let error = error { return completion(.failure(error)) }
                return completion(.success)
            }
        }
    }
}

// MARK: - Bookmark
extension FirebaseDataSource {
    func fetchBookmarks(for type: QuizType = .mixed, completion: @escaping(Result<[Bookmark], Error>) -> Void) {
        guard let user = Auth.auth().currentUser else { return completion(.failure(FirebaseError.userMissing)) }
        let ref: Query = Firestore.firestore().collection(Bookmark.collectionName)
        if type != .mixed { ref.whereField(AttibuteKey.type, isEqualTo: type.rawValue) }
        
        ref.whereField(AttibuteKey.userID, isEqualTo: user.uid).getDocuments { snapshot, error in
            if let error = error { return completion(.failure(error)) }
            guard let snapshot = snapshot else { return completion(.failure(FirebaseError.snapshotMissing)) }
            
            let bookmarks: [Bookmark] = snapshot.documentChanges
                .filter { $0.type == .added }
                .compactMap { try? Bookmark(snapshot: $0.document) }
            
            return completion(.success(bookmarks))
        }
    }
    func addBookmark(for itemID: String, as type: QuizType, completion: @escaping(Result<String, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else { return completion(.failure(FirebaseError.userMissing)) }
        let newRef = Firestore.firestore().collection(Bookmark.collectionName).document()
        _ = newRef.setData(from: Bookmark(userID: user.uid, itemID: itemID, type: type))
        return completion(.success(newRef.documentID))
    }
    func removeBookmark(for id: String, completion: @escaping(VoidResult) -> Void) {
        Firestore.firestore().collection(Bookmark.collectionName).document(id).delete() { error in
            if let error = error {
                return completion(.failure(error))
            } else {
                return completion(.success)
            }
        }
    }
}
