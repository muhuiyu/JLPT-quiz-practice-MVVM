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
    enum UserInfoKey {
        static let email = "email"
        static let name = "name"
        static let profilePhotoURL = "profilePhotoURL"
        static let age = "age"
        static let streakDays = "streakDays"
        static let numberOfAnsweredQuestions = "numberOfAnsweredQuestions"
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
// MARK: - Fetch Quizzes
extension FirebaseDataSource {
    private func fetchQuizIds(atLevel level: QuizLevel, withType type: QuizType, callback: @escaping (_ data: [String], _ error: Error?) -> Void) {
        var ref = Firestore.firestore().collection(CollectionName.quizzes).whereField("type", isEqualTo: type.rawValue)
        
        if level != .all {
            ref = ref.whereField("level", isEqualTo: level.rawValue)
        }
        
        ref.getDocuments { snapshot, error in
            if let error = error {
                return callback([], error)
            }
            
            guard let snapshot = snapshot else {
                return callback([], FirebaseError.snapshotMissing)
            }
            
            let quizIDs: [String] = snapshot
                .documentChanges
                .filter { $0.type == .added }
                .map { $0.document.documentID }
            
            return callback(quizIDs, nil)
        }
    }

    func fetchQuizzes(atIDList ids: [String], callback: @escaping (_ data: [Quiz], _ error: Error?) -> Void) {
        let dispatchGroup = DispatchGroup()
        var results = [Quiz]()
        let ref = Firestore.firestore().collection(CollectionName.quizzes)
        
        var i = 0
        while i < ids.count {
            dispatchGroup.enter()
            
            let endIndex = i + Constants.maximumNumberOfFetchRequest < ids.count ? i + Constants.maximumNumberOfFetchRequest : ids.count
            let slicedList: [String] = Array(ids[i ..< endIndex])
            
            ref.whereField(.documentID(), in: slicedList).getDocuments { (snapshot, error) in
                if let error = error {
                    return callback([], error)
                }
                guard let snapshot = snapshot else { return callback([], FirebaseError.snapshotMissing) }
                results += snapshot
                    .documentChanges
                    .filter { $0.type == .added }
                    .compactMap { change in
                        try? Quiz(snapshot: change.document)
                    }
                dispatchGroup.leave()
            }
            i += Constants.maximumNumberOfFetchRequest
        }
        dispatchGroup.notify(queue: .main) {
            return callback(results, nil)
        }
    }
    
    // TODO: consider user stats, level and type to generate question set
    /// generate question set based on user stats
    func getQuizSet(atLevel level: QuizLevel, withType type: QuizType, containQuestions number: Int, callback: @escaping (_ data: [Quiz], _ error: Error?) -> Void) {
        // get user stats -> fetch ids
//        self.fetchUserStats(atLevel: level, withType: type) { answeredQuizIDs, skipIDs, error in
//            if let error = error { return callback([], error) }
//
//            self.fetchQuizIDs(atLevel: level, withType: type) { (allQuizIDs, error) in
//                if let error = error { return callback([], error) }
//                let resultIds = self.selectQuizIdToSet(answeredList: answeredQuizIDs, skippedList: skipIDs, allList: allQuizIDs, returnQuestions: number)
//
//                self.fetchQuizzes(atIDList: resultIds) { (results, error) in
//                    if let error = error { return callback([], error) }
//                    return callback(results.shuffled(), error)
//                }
//            }
//        }
    }
}
