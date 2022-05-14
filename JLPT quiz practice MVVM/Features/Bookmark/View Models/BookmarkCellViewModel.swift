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
    var displayTitle: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    init() {
        bookmarkItem
            .asObservable()
            .subscribe(onNext: { value in
                if let value = value {
                    self.displayTitle.accept(value.bookmark.itemID)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension BookmarkCellViewModel {
    
}


