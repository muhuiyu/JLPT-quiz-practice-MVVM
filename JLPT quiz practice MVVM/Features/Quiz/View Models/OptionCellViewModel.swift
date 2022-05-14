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
    var isAnswerRevealed: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var displayTitle: BehaviorRelay<String> = BehaviorRelay(value: "")
    var displayButtonString: String { return "View More" }
    
    init() {
        option
            .asObservable()
            .subscribe(onNext: { value in
                if let value = value {
                    self.displayTitle.accept(value.title)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension OptionCellViewModel {
    
}

