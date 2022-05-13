//
//  QuizConfigViewModel.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import Foundation
import RxRelay

class QuizConfigViewModel {
    var config: BehaviorRelay<HomeViewModel.CellContent> = BehaviorRelay(value: HomeViewModel.CellContent(title: "", options: []))
    var selectedValue: BehaviorRelay<String?> = BehaviorRelay(value: nil)
}

extension QuizConfigViewModel {
    
}

