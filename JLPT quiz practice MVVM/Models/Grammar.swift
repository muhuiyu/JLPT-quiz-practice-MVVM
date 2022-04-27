//
//  Grammar.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import FirebaseFirestore

struct Grammar: Identifiable, Codable {
    let id: String
    let title: String
    let meaning: String
    let formation: String
    let examples: [String]
    let remark: String
    let relatedGrammar: [String]
    
    private struct GrammarData: Codable {
        let title: String
        let meaning: String
        let formation: String
        let examples: [String]
        let remark: String
        let relatedGrammar: [String]
        
        private enum CodingKeys: String, CodingKey {
            case title
            case meaning
            case formation
            case examples
            case remark
            case relatedGrammar
        }

        init(from decoder: Decoder) throws {
            var container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decode(String.self, forKey: .title)
            meaning = try container.decode(String.self, forKey: .meaning)
            formation = try container.decode(String.self, forKey: .formation)
            examples = try container.decode([String].self, forKey: .examples)
            remark = try container.decode(String.self, forKey: .remark)
            relatedGrammar = try container.decode([String].self, forKey: .relatedGrammar)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = try encoder.container(keyedBy: CodingKeys.self)
            try container.encode(title, forKey: .title)
            try container.encode(meaning, forKey: .meaning)
            try container.encode(formation, forKey: .formation)
            try container.encode(examples, forKey: .examples)
            try container.encode(remark, forKey: .remark)
            try container.encode(relatedGrammar, forKey: .relatedGrammar)
        }
    }
    
    init?(document: DocumentSnapshot) throws {
        self.id = document.documentID
        guard let data = try document.data() as? GrammarData else { return nil }
        title = data.title
        meaning = data.meaning
        formation = data.formation
        examples = data.examples
        remark = data.remark
        relatedGrammar = data.relatedGrammar
    }
//    init(id: String, title: String, meaning: String, formation: String, examples: [String], remark: String, relatedGrammar: [String]) {
//        self.id = id
//        self.title = title
//        self.meaning = meaning
//        self.formation = formation
//        self.examples = examples
//        self.remark = remark
//        self.relatedGrammar = relatedGrammar
//    }
}
