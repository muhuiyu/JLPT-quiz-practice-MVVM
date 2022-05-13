//
//  UserStats.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/12/22.
//

import FirebaseFirestore

struct UserStats: Codable, Identifiable {
    let id: String
    let streakDays: Int
    let numberOfAnsweredQuestions: Int
    let exp: Int
    
    private struct UserStatsData: Codable {
        let streakDays: Int
        let numberOfAnsweredQuestions: Int
        let exp: Int
        
        private enum CodingKeys: String, CodingKey {
            case streakDays
            case numberOfAnsweredQuestions
            case exp
        }
        
        init(from decoder: Decoder) throws {
            var container = try decoder.container(keyedBy: CodingKeys.self)
            streakDays = try container.decode(Int.self, forKey: .streakDays)
            numberOfAnsweredQuestions = try container.decode(Int.self, forKey: .numberOfAnsweredQuestions)
            exp = try container.decode(Int.self, forKey: .exp)
        }
        func encode(to encoder: Encoder) throws {
            var container = try encoder.container(keyedBy: CodingKeys.self)
            try container.encode(streakDays, forKey: .streakDays)
            try container.encode(numberOfAnsweredQuestions, forKey: .numberOfAnsweredQuestions)
            try container.encode(exp, forKey: .exp)
        }
    }
    
    init(snapshot: DocumentSnapshot) throws {
        id = snapshot.documentID
        let data = try snapshot.data(as: UserStatsData.self)
        streakDays = data.streakDays
        numberOfAnsweredQuestions = data.numberOfAnsweredQuestions
        exp = data.exp
    }
}
