//
//  BookmarkSection.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/14/22.
//

import RxDataSources

struct BookmarkSection: Codable {
    var header: String
    var items: [Item]
    
    init(header: String, items: [Item]) {
        self.header = header
        self.items = items
    }
}

extension BookmarkSection {
    private enum CodingKeys: String, CodingKey {
        case header
        case items
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        header = try container.decode(String.self, forKey: .header)
        items = try container.decode([Item].self, forKey: .items)
    }
}

extension BookmarkSection: SectionModelType {
    typealias Item = BookmarkItem
    
    init(original: BookmarkSection, items: [Item]) {
        self = original
        self.items = items
    }
}

