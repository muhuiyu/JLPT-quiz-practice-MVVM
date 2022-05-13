//
//  FirebaseDataSource.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import Foundation
import Firebase

class FirebaseDataSource: NSObject {
    
    static let shared = FirebaseDataSource()
    
    struct CollectionName {
        static let quizzes = "quizzes"
        static let kanjis = "kanjis"
        static let vocabs = "vocabs"
        static let grammars = "grammars"
        static let userQuizStats = "userQuizStats"
        static let userBookmarks = "userBookmarks"
        static let users = "users"
        static let userStats = "userStats"
    }
    struct AttibuteKey {
        static let userID = "userID"
        static let email = "email"
        static let name = "name"
        static let profilePhotoURL = "profilePhotoURL"
        static let age = "age"
        static let streakDays = "streakDays"
        static let numberOfAnsweredQuestions = "numberOfAnsweredQuestions"
        static let type = "type"
        static let level = "level"
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
    }
}
// MARK: - User
extension FirebaseDataSource {
    func getUserProfileImage() -> URL? {
        guard let user = Auth.auth().currentUser else { return nil }
        return user.photoURL
    }
    private func fetchUserStats(callback: @escaping (_ stats: UserStats?, _ error: Error?) -> Void) {
        guard let user = Auth.auth().currentUser else { return callback(nil, FirebaseError.userMissing) }
        let ref = Firestore.firestore().collection(CollectionName.userStats)
        
        ref.whereField(AttibuteKey.userID, isEqualTo: user.uid).getDocuments { snapshot, error in
            if let error = error {
                return callback(nil, error)
            }
            guard let snapshot = snapshot else { return callback(nil, FirebaseError.snapshotMissing) }
            if snapshot.documentChanges.count != 1 { return callback(nil, FirebaseError.snapshotMissing) }

            do {
                let entry = try UserStats(snapshot: snapshot.documentChanges[0].document)
                return callback(entry, nil)
            } catch {
                return callback(nil, FirebaseError.entryInitFailure)
            }
        }
    }
}

// MARK: - Fetch grammar, vocab, kanji entries by ID
extension FirebaseDataSource {
    func fetchGrammarEntry(at id: String, callback: @escaping (_ data: Grammar?, _ error: Error?) -> Void) {
        let ref = Firestore.firestore().collection(CollectionName.grammars)
        ref.document(id).getDocument { (document, error) in
            if let error = error { return callback(nil, error) }
            guard let document = document else { return callback(nil, FirebaseError.snapshotMissing) }
            
            do {
                let entry = try Grammar(snapshot: document)
                return callback(entry, nil)
            } catch {
                return callback(nil, FirebaseError.entryInitFailure)
            }
        }
    }
    func fetchVocabEntry(at id: String, callback: @escaping (_ data: Vocab?, _ error: Error?) -> Void) {
        let ref = Firestore.firestore().collection(CollectionName.vocabs)
        ref.document(id).getDocument { (document, error) in
            if let error = error { return callback(nil, error) }
            guard let document = document else { return callback(nil, FirebaseError.snapshotMissing) }
            
            do {
                let entry = try Vocab(snapshot: document)
                return callback(entry, nil)
            } catch {
                return callback(nil, FirebaseError.entryInitFailure)
            }
        }
    }
    func fetchKanjiEntry(at id: String, callback: @escaping (_ data: Kanji?, _ error: Error?) -> Void) {
        let ref = Firestore.firestore().collection(CollectionName.kanjis)
        ref.document(id).getDocument { (document, error) in
            if let error = error { return callback(nil, error) }
            guard let document = document else { return callback(nil, FirebaseError.snapshotMissing) }
            
            do {
                let entry = try Kanji(snapshot: document)
                return callback(entry, nil)
            } catch {
                return callback(nil, FirebaseError.entryInitFailure)
            }
        }
    }
}
// MARK: - Fetch Quizzes based on IDs
extension FirebaseDataSource {
    func fetchQuiz(atID id: Quiz.ID, callback: @escaping (_ quiz: Quiz?, _ error: Error?) -> Void) {
        let ref = Firestore.firestore().collection(CollectionName.quizzes)
        
        ref.whereField(.documentID(), isEqualTo: id).getDocuments { snapshot, error in
            if let error = error { return callback(nil, error) }
            guard let snapshot = snapshot, snapshot.count == 1 else { return callback(nil, FirebaseError.snapshotMissing) }
                    
            let quiz = try? Quiz(snapshot: snapshot.documents[0])
            return callback(quiz, nil)
        }
    }
}

// MARK: - Generate Quiz set
extension FirebaseDataSource {
    /// Fetch all quizzes based on user query (level and type)
    private func fetchQuizIDs(with configuration: QuizConfig, callback: @escaping (_ data: [String], _ error: Error?) -> Void) {
        var ref: Query = Firestore.firestore().collection(CollectionName.quizzes)
        
        if configuration.level != .all { ref = ref.whereField(AttibuteKey.level, isEqualTo: configuration.level.rawValue) }
        if configuration.type != .mixed { ref = ref.whereField(AttibuteKey.type, isEqualTo: configuration.type.rawValue) }
        
        ref.getDocuments { snapshot, error in
            if let error = error { return callback([], error) }
            guard let snapshot = snapshot else { return callback([], FirebaseError.snapshotMissing) }
            
            let quizIDs: [String] = snapshot
                .documentChanges
                .filter { $0.type == .added }
                .map { $0.document.documentID }
            
            return callback(quizIDs, nil)
        }
    }
    /// Fetch past question result (question answered, question mastered) of current user based on user query
    private func fetchPastQuestionResult(with configuration: QuizConfig, callback: @escaping (_ answeredQuizIDs: [String], _ skippedQuizIDs: [String], _ error: Error?) -> Void) {
        guard let user = Auth.auth().currentUser else { return callback([], [], FirebaseError.userMissing) }
        var ref = Firestore.firestore().collection(CollectionName.userQuizStats).whereField(AttibuteKey.userID, isEqualTo: user.uid)

        if configuration.level != .all { ref = ref.whereField(AttibuteKey.level, isEqualTo: configuration.level.rawValue) }
        if configuration.type != .mixed { ref = ref.whereField(AttibuteKey.type, isEqualTo: configuration.type.rawValue) }
        
        ref.getDocuments { snapshot, error in
            if let error = error { return callback([], [], error) }
            guard let snapshot = snapshot else { return callback([], [], FirebaseError.snapshotMissing) }
            if snapshot.documentChanges.isEmpty { return callback([], [], nil) }

            var questionStatsRawData: [UserQuestionStats] = snapshot.documentChanges
                .filter { $0.type == .added }
                .compactMap { try? UserQuestionStats(snapshot: $0.document) }
            
            // 50% possilibity to return quizzes which user answered wrongly
            if Bool.random() {
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
    func generateQuizList(with configuration: QuizConfig, callback: @escaping (_ data: [Quiz.ID], _ error: Error?) -> Void) {
        
        var answeredQuizIDs = [String]()
        var skippedQuizIDs = [String]()
        var allQuizIDs = [String]()
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        fetchPastQuestionResult(with: configuration) { answered, skipped, error in
            if let error = error { return callback([], error) }
            answeredQuizIDs = answered
            skippedQuizIDs = skipped
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchQuizIDs(with: configuration) { all, error in
            if let error = error { return callback([], error) }
            allQuizIDs = all
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            let selectedIDs = self.selectQuizIdToSet(answeredQuizIDs, skippedQuizIDs, allQuizIDs, select: configuration.numberOfQuestions)
            return callback(selectedIDs.shuffled(), nil)
        }
    }
}
