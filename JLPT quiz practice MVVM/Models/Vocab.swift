//
//  Vocab.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFirestoreCombineSwift

struct Vocab: Identifiable, Codable, FirebaseFetchable, Entry {
    @DocumentID var id: String?
    var title: String
    var meaning: String
    
    static let collectionName = "vocabs"
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
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(title, forKey: .title)
            try container.encode(meaning, forKey: .meaning)
        }
    }
    
    init?(snapshot: DocumentSnapshot) throws {
        let data = try snapshot.data(as: VocabData.self)
        title = data.title
        meaning = data.meaning
    }
}
