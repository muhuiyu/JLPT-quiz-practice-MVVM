//
//  FirebaseDataSource.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import Foundation
import Firebase

class FirebaseDataSource: NSObject {
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

// MARK: - Fetch quiz by ID
extension FirebaseDataSource {
    func fetchGrammarEntry(at id: String, callback: @escaping (_ data: Grammar?, _ error: Error?) -> Void) {
        let ref = Firestore.firestore().collection(CollectionName.grammars)
        ref.document(id).getDocument { (document, error) in
            if let error = error { return callback(nil, error) }
            guard let document = document else { return callback(nil, FirebaseError.snapshotMissing) }
            
            do {
                let entry = try Grammar(document: document)
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
                let entry = try Vocab(document: document)
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
                let entry = try Kanji(document: document)
                return callback(entry, nil)
            } catch {
                return callback(nil, FirebaseError.entryInitFailure)
            }
        }
    }
}
// MARK: - Fetch Quizzes
extension FirebaseDataSource {
    func fetchQuizIds(atLevel level: QuizLevel, withType type: QuizType, callback: @escaping (_ data: [String], _ error: Error?) -> Void) {
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
            
            var quizIDs: [String] = snapshot
                .documentChanges
                .filter { $0.type == .added }
                .map { $0.document.documentID }
            
            return callback(quizIDs, nil)
        }
    }
}
