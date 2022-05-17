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
    var currentIndex: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    var numberOfCorrectAnswers = 0
    
    private(set) var state: BehaviorRelay<State> = BehaviorRelay(value: .questionLoaded)
    var questionViewController = QuestionViewController()
    
    enum State {
        case questionLoaded
        case answered(Bool)
        case sessionSummaryPresented
        case sessionEnded
    }
    
    init() {
        quizIDs
            .asObservable()
            .subscribe(onNext: { _ in
                self.currentIndex.accept(0)
            })
            .disposed(by: disposeBag)
        
        currentIndex
            .asObservable()
            .subscribe(onNext: { value in
                if !self.quizIDs.value.isEmpty, let id = self.quizIDs.value[value] {
                    self.questionViewController.viewModel.quizID.accept(id)
                }
            })
            .disposed(by: disposeBag)
        
        state.accept(.questionLoaded)
        configureQuestionViewController()
    }
}

extension SessionViewModel {
    var displaySessionTitleString: String { return "test \(currentIndex.value + 1)/\(quizIDs.value.count)" }
    var optionEntryNotFoundAlert: UIAlertController {
        let alert = UIAlertController(title: "Oops, no explanation!",
                                      message: "We will add this to the database very soon :(",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK, got it!", style: .default))
        return alert
    }
    var sessionSummaryAlert: UIAlertController {
        let alert =  UIAlertController(title: "Well done!",
                                       message: "You got \(numberOfCorrectAnswers) out of \(quizIDs.value.count) :)",
                                       preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay, got it!", style: .default, handler: { _ in
            self.state.accept(.sessionEnded)
        }))
        return alert
    }
    func getSoundFileName(isCorrect: Bool) -> String { return isCorrect ? "correct.m4a" : "wrong.m4a" }
}

// MARK: - API to QuestionViewModel
extension SessionViewModel {
    func didAnswer(_ quizID: String, isCorrect: Bool) {
        if isCorrect {
            numberOfCorrectAnswers += 1
        }
        state.accept(.answered(isCorrect))
        FirebaseDataSource.shared.updateQuestionAttemptRecord(for: quizID, answer: isCorrect) { result in
            switch result {
            case .success:
                return
            case .failure(let error):
                print(error)
            }
        }
    }
    func didTapContinue() {
        if isSessionCompleted {
            state.accept(.sessionSummaryPresented)
        } else {
            currentIndex.accept(currentIndex.value + 1)
            state.accept(.questionLoaded)
        }
    }
    private var isSessionCompleted: Bool {
        return currentIndex.value == quizIDs.value.count - 1
    }
}

extension SessionViewModel {
    var currentProgress: Double { return Double(currentIndex.value) / Double(quizIDs.value.count - 1) }
}

// MARK: - Configure QuestionViewController
extension SessionViewModel {
    private func configureQuestionViewController() {
        questionViewController.viewModel.didTapContinueHandler = { [weak self] in
            self?.didTapContinue()
        }
        questionViewController.viewModel.didAnswerHandler = { [weak self] (id, isCorrect) in
            self?.didAnswer(id, isCorrect: isCorrect)
        }
    }

}
