//
//  Quiz.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFirestoreCombineSwift

struct Quiz: Identifiable, Codable, FirebaseFetchable {
    @DocumentID var id: String?
    var question: String
    var type: QuizType
    var level: QuizLevel
    var options: [QuizOption]
    
    static let collectionName = "quizzes"
    
    private struct QuizData: Codable {
        let question: String
        let options: [QuizOption]
        let type: QuizType
        let level: QuizLevel
        
        private enum CodingKeys: String, CodingKey {
            case question
            case options
            case type
            case level
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            question = try container.decode(String.self, forKey: .question)
            options = try container.decode([QuizOption].self, forKey: .options)
            type = try container.decode(QuizType.self, forKey: .type)
            level = try container.decode(QuizLevel.self, forKey: .level)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(question, forKey: .question)
            try container.encode(options, forKey: .options)
            try container.encode(type.rawValue, forKey: .type)
            try container.encode(level.rawValue, forKey: .level)
        }
    }
    
    init(snapshot: DocumentSnapshot) throws {
        id = snapshot.documentID
        let data = try snapshot.data(as: QuizData.self)
        question = data.question
        options = data.options.shuffled()
        type = data.type
        level = data.level
    }
}

struct QuizOption: Codable, Item {
    var id: String
    var title: String
    var linkedEntryId: String
    let isAnswer: Bool
    var state: State = .empty
    
    enum State {
        case empty
        case selected
        case unselected
    }
    
    private enum CodingKeys: String, CodingKey {
        case title = "value"
        case linkedEntryId = "linkedEntry"
        case isAnswer
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID().uuidString
        title = try container.decode(String.self, forKey: .title)
        linkedEntryId = try container.decode(String.self, forKey: .linkedEntryId)
        isAnswer = try container.decode(Bool.self, forKey: .isAnswer)
        state = .empty
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(linkedEntryId, forKey: .linkedEntryId)
        try container.encode(isAnswer, forKey: .isAnswer)
    }
    init(id: String, title: String, linkedEntryId: String, isAnswer: Bool, state: QuizOption.State) {
        self.id = id
        self.title = title
        self.linkedEntryId = linkedEntryId
        self.isAnswer = isAnswer
        self.state = .empty
    }
}

enum QuizLevel: String, Codable {
    case n1
    case n2
    case n3
    case n4
    case n5
    case all
}
enum QuizType: String, Codable {
    case mixed
    case kanji
    case grammar
    case vocab
    
    var collectionName: String {
        switch self {
        case .grammar: return Grammar.collectionName
        case .kanji: return Kanji.collectionName
        case .vocab: return Vocab.collectionName
        default: return ""
        }
    }
}
struct QuizConfig {
    let type: QuizType
    let level: QuizLevel
    let numberOfQuestions: Int
}
