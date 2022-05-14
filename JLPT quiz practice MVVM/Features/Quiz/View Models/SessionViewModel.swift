//
//  SessionViewModel.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import RxSwift
import RxRelay
import UIKit

class SessionViewModel {
    private let disposeBag = DisposeBag()
    
    var quizIDs: BehaviorRelay<[Quiz.ID]> = BehaviorRelay(value: [])
    var currentIndex = 0
    var numberOfCorrectAnswers = 0
    
    var state: BehaviorRelay<State> = BehaviorRelay(value: .loadQuestion)
    
    enum State {
        case loadQuestion
        case loadDetail
        case presentSessionSummary
        case endSession
    }
    
    init() {
        state.accept(.loadQuestion)
    }
}

extension SessionViewModel {
    var displaySessionTitleString: String { return "test \(currentIndex + 1)/\(quizIDs.value.count)" }
    
    var sessionSummaryAlert: UIAlertController {
        let alert =  UIAlertController(title: "Well done!",
                                       message: "You got \(numberOfCorrectAnswers) out of \(quizIDs.value.count) :)",
                                       preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay, got it!", style: .default, handler: { _ in
            self.state.accept(.endSession)
        }))
        return alert
    }
}

extension SessionViewModel {
    func didTapContinue() {
        if isSessionCompleted {
            state.accept(.presentSessionSummary)
        } else {
            currentIndex += 1
            state.accept(.loadQuestion)
        }
    }
    private var isSessionCompleted: Bool {
        return currentIndex == quizIDs.value.count - 1
    }
}

extension SessionViewModel {
    var currentProgress: Double { return Double(currentIndex) / Double(quizIDs.value.count - 1) }
    
    func questionViewController() -> QuestionViewController {
        let viewController = QuestionViewController()
        let viewModel = QuestionViewModel()
        if let id = quizIDs.value[currentIndex] {
            viewModel.quizID.accept(id)
        }
        viewModel.state
            .asObservable()
            .subscribe(onNext: { state in
                switch state {
                case .didTapContinue:
                    self.didTapContinue()
                case .answeredCorrectly:
                    self.numberOfCorrectAnswers += 1
                default:
                    return
                }
            })
            .disposed(by: disposeBag)
        viewController.viewModel = viewModel
        return viewController
    }
}
