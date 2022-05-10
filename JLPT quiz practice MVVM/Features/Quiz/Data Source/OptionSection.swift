//
//  OptionSection.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/5/22.
//

import RxDataSources

protocol Item {
    var id: String { get set }
    var title: String { get set }
}

struct OptionSection: Codable {
    var header: String
    var items: [Item]
    
    init(header: String, items: [Item]) {
        self.header = header
        self.items = items
    }
}

extension OptionSection {
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

extension OptionSection: SectionModelType {
    typealias Item = QuizOption
    
    init(original: OptionSection, items: [Item]) {
        self = original
        self.items = items
    }
}
