//
//  EntryDetailViewModel.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/14/22.
//

import Foundation
import RxSwift
import RxRelay
import UIKit

class EntryDetailViewModel {
    private let disposeBag = DisposeBag()
    
    var entryConfig: BehaviorRelay<Config> = BehaviorRelay(value: Config(id: "", type: .mixed))
    private(set) var entry: BehaviorRelay<Entry?> = BehaviorRelay(value: nil)
    private(set) var isBookmarked: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var didTapRelatedItemHandler: ((_ entryConfig: Config) -> Void)?
    
    struct Config {
        let id: String
        let type: QuizType
    }
    
    init() {
        self.entryConfig
            .asObservable()
            .subscribe(onNext: { value in
                FirebaseDataSource.shared.fetchEntry(as: value.type, for: value.id) { result in
                    switch result {
                    case .failure(let error):
                        print(error)
                    case .success(let item):
                        self.entry.accept(item)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}

extension EntryDetailViewModel {
    var bookmarkItemImage: UIImage? { isBookmarked.value ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark") }
    var displayTitleLabelString: String? { return entry.value?.title }
    var displayMeaningLabelTitleString: String { return "意味" }
    var displayMeaningLabelContentString: String? { return entry.value?.meaning }
    var displayGrammarFormationLabelTitleString: String { return "接続" }
    var displayGrammarExamplesStackViewTitleString: String { return "例文" }
    var displayGrammarRemarkViewTitleString: String { return "解説" }
    var displayGrammarRelatedGrammersViewTitleString: String { return "類似文型" }
}

extension EntryDetailViewModel {
    @objc
    func didTapBookmark() {
        if self.isBookmarked.value {
            FirebaseDataSource.shared.removeBookmark(for: entryConfig.value.id) { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success:
                    break
                }
            }
            self.isBookmarked.accept(false)
        } else {
            FirebaseDataSource.shared.addBookmark(for: entryConfig.value.id, as: entryConfig.value.type) { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success:
                    break
                }
            }
            self.isBookmarked.accept(true)
        }
    }
    func getGrammarItems(for ids: [String], completion: @escaping(Result<[RelatedItemListView.RelatedItem], Error>) -> Void) {
        FirebaseDataSource.shared.fetchMultiple(as: .grammar, for: ids) { result in
            switch result {
            case .failure(let error):
                return completion(.failure(error))
            case .success(let grammars):
                guard let grammars = grammars as? [Grammar] else { return }
                let items: [RelatedItemListView.RelatedItem] = grammars
                    .compactMap { grammar in
                        if let id = grammar.id {
                            return RelatedItemListView.RelatedItem(id: id, title: grammar.title)
                        } else {
                             return nil
                        }
                    }
                return completion(.success(items))
            }
        }
    }
//    func didTap(_ item: ) {
//
//    }
}

