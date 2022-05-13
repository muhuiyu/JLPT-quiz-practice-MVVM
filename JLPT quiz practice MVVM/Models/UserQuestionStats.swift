//
//  UserQuestionStats.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/13/22.
//

import FirebaseFirestore

struct UserQuestionStats: Codable, Identifiable {
    let id: String
    let quizID: String
    let level: QuizLevel
    let type: QuizType
    let numberOfAttempts: Int
    let numberOfSuccess: Int
    let isMastered: Bool
    
    private struct UserQuestionStatsData: Codable {
        let quizID: String
        let level: QuizLevel
        let type: QuizType
        let numberOfAttempts: Int
        let numberOfSuccess: Int
        let isMastered: Bool
        
        private enum CodingKeys: String, CodingKey {
            case quizID
            case level
            case type
            case numberOfAttempts
            case numberOfSuccess
            case isMastered
        }
        
        init(from decoder: Decoder) throws {
            var container = try decoder.container(keyedBy: CodingKeys.self)
            quizID = try container.decode(String.self, forKey: .quizID)
            level = try container.decode(QuizLevel.self, forKey: .level)
            type = try container.decode(QuizType.self, forKey: .type)
            numberOfAttempts = try container.decode(Int.self, forKey: .numberOfAttempts)
            numberOfSuccess = try container.decode(Int.self, forKey: .numberOfSuccess)
            isMastered = try container.decode(Bool.self, forKey: .isMastered)
        }
        func encode(to encoder: Encoder) throws {
            var container = try encoder.container(keyedBy: CodingKeys.self)
            try container.encode(quizID, forKey: .quizID)
            try container.encode(level, forKey: .level)
            try container.encode(type, forKey: .type)
            try container.encode(numberOfAttempts, forKey: .numberOfAttempts)
            try container.encode(numberOfSuccess, forKey: .numberOfSuccess)
            try container.encode(isMastered, forKey: .isMastered)
        }
    }
    
    init(snapshot: DocumentSnapshot) throws {
        id = snapshot.documentID
        let data = try snapshot.data(as: UserQuestionStatsData.self)
        quizID = data.quizID
        level = data.level
        type = data.type
        numberOfAttempts = data.numberOfAttempts
        numberOfSuccess = data.numberOfSuccess
        isMastered = data.isMastered
    }
}

extension UserQuestionStats: Comparable {
    static func < (lhs: UserQuestionStats, rhs: UserQuestionStats) -> Bool {
        return lhs.successRate < rhs.successRate
    }
    static func == (lhs: UserQuestionStats, rhs: UserQuestionStats) -> Bool {
        return lhs.successRate == rhs.successRate
    }
}
extension UserQuestionStats {
    var successRate: Double {
        return numberOfAttempts == 0 ? 0 : Double(numberOfSuccess) / Double(numberOfAttempts)
    }
}
