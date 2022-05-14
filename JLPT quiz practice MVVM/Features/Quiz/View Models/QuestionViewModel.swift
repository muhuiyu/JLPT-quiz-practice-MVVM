//
//  QuestionViewModel.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/5/22.
//

import Foundation
import RxSwift
import RxRelay
import RxDataSources

class QuestionViewModel {
    private let disposeBag = DisposeBag()
    private var quiz: BehaviorRelay<Quiz?> = BehaviorRelay(value: nil)
    
    lazy var dataSource = OptionDataSource.dataSource(self)
    var quizID: BehaviorRelay<String> = BehaviorRelay(value: "")
    var displayQuestionString: BehaviorRelay<String> = BehaviorRelay(value: "")
    var displayOptions: BehaviorRelay<[OptionSection]> = BehaviorRelay(value: [])
    var selectionOptionIndexPath: IndexPath?
    
    var selectedOptionEntryID: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    
    var state: BehaviorRelay<State> = BehaviorRelay(value: .loading)
    
    enum State {
        case loading
        case unanswered
        case answeredCorrectly
        case answeredWrongly
        case didReqestExplanation
        case didTapContinue
    }
    
    init() {
        self.quizID
            .asObservable()
            .subscribe(onNext: { value in
                if value != "" {
                    FirebaseDataSource.shared.fetch(Quiz.self, for: value) { result in
                        switch result {
                        case .success(let quiz):
                            self.state.accept(.unanswered)
                            self.quiz.accept(quiz)
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        self.quiz
            .asObservable()
            .subscribe(onNext: { value in
                if let value = value {
                    self.displayQuestionString.accept(value.question)
                    let optionSection = OptionSection(header: "", items: value.options)
                    self.displayOptions.accept([optionSection])
                }
            })
            .disposed(by: disposeBag)
    }
}

extension QuestionViewModel {
    var displayNextButtonString: String { return "Next" }
    var displayMasterButtonString: String { return "I mastered this question already" }
}

// MARK: - DidSelectOptions
extension QuestionViewModel {
    private func didAnswer(with option: QuizOption, at indexPath: IndexPath) {
        let isCorrect = option.isAnswer
        self.selectionOptionIndexPath = indexPath
        self.state.accept(isCorrect ? .answeredCorrectly : .answeredWrongly)
        
        FirebaseDataSource.shared.updateQuestionAttemptRecord(for: quizID.value, answer: isCorrect) { result in
            switch result {
            case .success:
                return
            case .failure(let error):
                print(error)
            }
        }
    }
    private func didRequestExplanation(for option: QuizOption) {
        
    }
    func didSelect(_ option: QuizOption, at indexPath: IndexPath) {
        switch state.value {
        case .unanswered:
            didAnswer(with: option, at: indexPath)
        case .answeredCorrectly, .answeredWrongly:
            didRequestExplanation(for: option)
        default:
            return
        }
    }
}

// MARK: - Actions after question answered
extension QuestionViewModel {
    func didRequestGoNextQuestion() {
        self.state.accept(.didTapContinue)
    }
    func didRequestBookmarkQuestion() {

    }
    func didRequestMasterQuestion() {
        FirebaseDataSource.shared.markQuestionAsMastered(for: quizID.value) { result in
            switch result {
            case .success:
                print("yeah")
            case .failure(let error):
                print(error)
            }
        }
    }
}
