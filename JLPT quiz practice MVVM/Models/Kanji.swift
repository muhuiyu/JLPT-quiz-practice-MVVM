//
//  Kanji.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import FirebaseFirestore

struct Kanji: Identifiable, Codable {
    let id: String
    let title: String
    let meaning: String
    
    private struct KanjiData: Codable {
        let title: String
        let meaning: String
        
        private enum CodingKeys: String, CodingKey {
            case title
            case meaning
        }
        
        init(from decoder: Decoder) throws {
            var container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decode(String.self, forKey: .title)
            meaning = try container.decode(String.self, forKey: .meaning)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = try encoder.container(keyedBy: CodingKeys.self)
            try container.encode(title, forKey: .title)
            try container.encode(meaning, forKey: .meaning)
        }
    }
    
    init?(document: DocumentSnapshot) throws {
        id = document.documentID
        guard let data = try document.data() as? KanjiData else { return nil }
        title = data.title
        meaning = data.meaning
    }
    
    init(id: String, title: String, meaning: String) {
        self.id = id
        self.title = title
        self.meaning = meaning
    }
}

extension Kanji {
    static let testEntries: [Kanji] = [
        Kanji(id: "kanji-kimi", title: "君", meaning: "you")
    ]
}
