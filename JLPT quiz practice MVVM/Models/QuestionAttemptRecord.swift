//
//  UserQuestionStats.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/13/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct QuestionAttemptRecord: Codable, Identifiable {
    @DocumentID var id: String?
    var quizID: String
    var userID: String
    var numberOfAttempts: Int
    var numberOfSuccess: Int
    var isMastered: Bool
    
    private struct UserQuestionStatsData: Codable {
        let quizID: String
        let userID: String
        let numberOfAttempts: Int
        let numberOfSuccess: Int
        let isMastered: Bool
        
        private enum CodingKeys: String, CodingKey {
            case quizID
            case userID
            case numberOfAttempts
            case numberOfSuccess
            case isMastered
        }
        
        init(from decoder: Decoder) throws {
            var container = try decoder.container(keyedBy: CodingKeys.self)
            quizID = try container.decode(String.self, forKey: .quizID)
            userID = try container.decode(String.self, forKey: .userID)
            numberOfAttempts = try container.decode(Int.self, forKey: .numberOfAttempts)
            numberOfSuccess = try container.decode(Int.self, forKey: .numberOfSuccess)
            isMastered = try container.decode(Bool.self, forKey: .isMastered)
        }
        func encode(to encoder: Encoder) throws {
            var container = try encoder.container(keyedBy: CodingKeys.self)
            try container.encode(quizID, forKey: .quizID)
            try container.encode(userID, forKey: .userID)
            try container.encode(numberOfAttempts, forKey: .numberOfAttempts)
            try container.encode(numberOfSuccess, forKey: .numberOfSuccess)
            try container.encode(isMastered, forKey: .isMastered)
        }
    }
    
    init(snapshot: DocumentSnapshot) throws {
        id = snapshot.documentID
        let data = try snapshot.data(as: UserQuestionStatsData.self)
        quizID = data.quizID
        userID = data.userID
        numberOfAttempts = data.numberOfAttempts
        numberOfSuccess = data.numberOfSuccess
        isMastered = data.isMastered
    }
    
    init(quizID: String, userID: String, didUserAnswerCorrectly isCorrect: Bool) {
        id = ""
        self.quizID = quizID
        self.userID = userID
        numberOfAttempts = 1
        numberOfSuccess = isCorrect ? 1 : 0
        isMastered = false
    }
}

extension QuestionAttemptRecord: Comparable {
    static func < (lhs: QuestionAttemptRecord, rhs: QuestionAttemptRecord) -> Bool {
        return lhs.successRate < rhs.successRate
    }
    static func == (lhs: QuestionAttemptRecord, rhs: QuestionAttemptRecord) -> Bool {
        return lhs.successRate == rhs.successRate
    }
}
extension QuestionAttemptRecord {
    var successRate: Double {
        return numberOfAttempts == 0 ? 0 : Double(numberOfSuccess) / Double(numberOfAttempts)
    }
}
