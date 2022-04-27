//
//  Quiz.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

struct Quiz: Identifiable, Codable {
    let id: String
    let question: String
    let options: [QuizOption]
}

extension Quiz {
    private enum CodingKeys: String, CodingKey {
        case id
        case question
        case options
    }
}

struct QuizOption: Codable {
    let value: String
    let isAnswer: Bool
}

extension QuizOption {
    private enum CodingKeys: String, CodingKey {
        case value
        case isAnswer
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
