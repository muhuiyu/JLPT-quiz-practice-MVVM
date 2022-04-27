//
//  Vocab.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import FirebaseFirestore

struct Vocab: Identifiable, Codable {
    let id: String
    let title: String
    let meaning: String
}

extension Vocab {
    private struct VocabData: Codable {
        let title: String
        let meaning: String
        
        private enum CodingKeys: String, CodingKey {
            case title
            case meaning
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
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
        guard let data = try document.data() as? VocabData else { return nil }
        title = data.title
        meaning = data.meaning
    }
}
