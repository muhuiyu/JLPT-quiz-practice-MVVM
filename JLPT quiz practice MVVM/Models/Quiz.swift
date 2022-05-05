//
//  Quiz.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import FirebaseFirestore
import FirebaseFirestoreCombineSwift

struct Quiz: Identifiable, Codable {
    let id: String
    let question: String
    let options: [QuizOption]
    
    private struct QuizData: Codable {
        let question: String
        let options: [QuizOption]
        
        private enum CodingKeys: String, CodingKey {
            case question
            case options
        }

        init(from decoder: Decoder) throws {
            var container = try decoder.container(keyedBy: CodingKeys.self)
            question = try container.decode(String.self, forKey: .question)
            options = try container.decode([QuizOption].self, forKey: .options)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = try encoder.container(keyedBy: CodingKeys.self)
            try container.encode(question, forKey: .question)
            try container.encode(options, forKey: .options)
        }
    }
    
    init(snapshot: DocumentSnapshot) throws {
        id = snapshot.documentID
        let data = try snapshot.data(as: QuizData.self)
        question = data.question
        options = data.options.shuffled()
    }
}

struct QuizOption: Codable {
    let value: String
    let isAnswer: Bool
    
    private enum CodingKeys: String, CodingKey {
        case value
        case isAnswer
    }
    init(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(String.self, forKey: .value)
        isAnswer = try container.decode(Bool.self, forKey: .isAnswer)
    }
    func encode(to encoder: Encoder) throws {
        var container = try encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(isAnswer, forKey: .isAnswer)
    }
}

enum QuizLevel: String {
    case n1
    case n2
    case n3
    case n4
    case n5
    case all
}
enum QuizType: String {
    case kanji
    case grammar
    case vocab
}
