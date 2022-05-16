//
//  Grammar.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFirestoreCombineSwift

struct Grammar: Identifiable, Codable, FirebaseFetchable, Entry {
    @DocumentID var id: String?
    var title: String
    var meaning: String
    var formation: String
    var examples: [String]
    var remark: String
    var relatedGrammar: [String]
    
    static let collectionName = "grammars"
    
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
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decode(String.self, forKey: .title)
            meaning = try container.decode(String.self, forKey: .meaning)
            formation = try container.decode(String.self, forKey: .formation)
            examples = try container.decode([String].self, forKey: .examples)
            remark = try container.decode(String.self, forKey: .remark)
            relatedGrammar = try container.decode([String].self, forKey: .relatedGrammar)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(title, forKey: .title)
            try container.encode(meaning, forKey: .meaning)
            try container.encode(formation, forKey: .formation)
            try container.encode(examples, forKey: .examples)
            try container.encode(remark, forKey: .remark)
            try container.encode(relatedGrammar, forKey: .relatedGrammar)
        }
    }
    
    init(snapshot: DocumentSnapshot) throws {
        id = snapshot.documentID
        let data = try snapshot.data(as: GrammarData.self)
        title = data.title
        meaning = data.meaning
        formation = data.formation
        examples = data.examples
        remark = data.remark
        relatedGrammar = data.relatedGrammar
    }
}
