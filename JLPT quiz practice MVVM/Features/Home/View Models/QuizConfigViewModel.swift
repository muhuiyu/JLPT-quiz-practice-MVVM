//
//  QuizConfigViewModel.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import Foundation
import RxRelay

class QuizConfigViewModel {
    var config: BehaviorRelay<HomeViewModel.QuizConfig> = BehaviorRelay(value: HomeViewModel.QuizConfig(item: "", options: []))
    var selectedValue: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    
    init() {
        
    }
}

extension QuizConfigViewModel {
    
}

