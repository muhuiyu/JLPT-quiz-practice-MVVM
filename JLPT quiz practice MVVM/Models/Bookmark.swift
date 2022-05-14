//
//  Bookmark.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/14/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct Bookmark: Identifiable, Codable, FirebaseFetchable {
    @DocumentID var id: String?
    var userID: String
    var itemID: String
    var type: QuizType
    
    static var collectionName: String = "userBookmarks"
    
    private struct BookmarkData: Codable {
        let userID: String
        let itemID: String
        let type: QuizType
        
        private enum CodingKeys: String, CodingKey {
            case userID
            case itemID
            case type
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            userID = try container.decode(String.self, forKey: .userID)
            itemID = try container.decode(String.self, forKey: .itemID)
            type = try container.decode(QuizType.self, forKey: .type)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(userID, forKey: .userID)
            try container.encode(itemID, forKey: .itemID)
            try container.encode(type.rawValue, forKey: .type)
        }
    }
    
    init(snapshot: DocumentSnapshot) throws {
        let data = try snapshot.data(as: BookmarkData.self)
        userID = data.userID
        itemID = data.itemID
        type = data.type
    }

    init(userID: String, itemID: String, type: QuizType) {
        self.id = ""
        self.userID = userID
        self.itemID = itemID
        self.type = type
    }
}


struct BookmarkItem: Codable, Item {
    var id: String
    var title: String
    var bookmark: Bookmark
    
    private enum CodingKeys: String, CodingKey {
        case title
        case bookmark
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID().uuidString
        title = try container.decode(String.self, forKey: .title)
        bookmark = try container.decode(Bookmark.self, forKey: .bookmark)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(bookmark, forKey: .bookmark)
    }
    
    init(bookmark: Bookmark) {
        id = UUID().uuidString
        title = bookmark.itemID
        self.bookmark = bookmark
    }
}
