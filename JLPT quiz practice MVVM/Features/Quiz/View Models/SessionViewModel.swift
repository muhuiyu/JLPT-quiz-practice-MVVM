//
//  SessionViewModel.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import RxSwift
import RxRelay

class SessionViewModel {
    private let disposeBag = DisposeBag()
    
    var quizIDs: BehaviorRelay<[Quiz.ID]> = BehaviorRelay(value: [])
    var currentIndex: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    var numberOfCorrectAnswers = 0
    
    init() {
        
    }
}

extension SessionViewModel {
    var displaySessionTitle: String { return "test" }
}

extension SessionViewModel {
    func didTapContinue() {
        if isSessionCompleted {
            
        } else {
            currentIndex.accept(currentIndex.value + 1)
        }
    }
    private var isSessionCompleted: Bool {
        return false
    }
}

extension SessionViewModel {
    func questionViewController() -> QuestionViewController {
        let viewController = QuestionViewController()
        let viewModel = QuestionViewModel()
        viewModel.quizID.accept(quizIDs.value[currentIndex.value])
        viewController.viewModel = viewModel
        return viewController
    }
}
