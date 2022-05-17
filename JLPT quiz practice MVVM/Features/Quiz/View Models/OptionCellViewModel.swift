//
//  OptionCellViewModel.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/5/22.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OptionCellViewModel {
    private let disposeBag = DisposeBag()
    
    // MARK: - Reactive properties
    var option: BehaviorRelay<QuizOption?> = BehaviorRelay(value: nil)
    var state: BehaviorRelay<QuizOption.State> = BehaviorRelay(value: .empty)
    var displayTitle: BehaviorRelay<String> = BehaviorRelay(value: "")
    var displayButtonString: String { return "View More" }
    
    var isLinkedEntryIdValid: Bool {
        if let id = option.value?.linkedEntryId {
            return !id.isEmpty
        } else {
            return false
        }
    }
    
    init() {
        option
            .asObservable()
            .subscribe(onNext: { value in
                if let value = value {
                    self.displayTitle.accept(value.title)
                    self.state.accept(value.state)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension OptionCellViewModel {
    
}

