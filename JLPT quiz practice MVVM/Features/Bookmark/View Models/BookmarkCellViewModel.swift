//
//  BookmarkCellViewModel.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/14/22.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class BookmarkCellViewModel {
    private let disposeBag = DisposeBag()

    var bookmarkItem: BehaviorRelay<BookmarkItem?> = BehaviorRelay(value: nil)
    var displayTitle: BehaviorRelay<String> = BehaviorRelay(value: "default")
    
    init() {
        bookmarkItem
            .asObservable()
            .subscribe(onNext: { value in
                if let value = value {
                    FirebaseDataSource.shared.fetchEntry(as: value.bookmark.type, for: value.bookmark.itemID) { result in
                        switch result {
                        case .failure(let error):
                            print(error)
                        case .success(let item):
                            self.displayTitle.accept(item.title)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}

extension BookmarkCellViewModel {
    
}


