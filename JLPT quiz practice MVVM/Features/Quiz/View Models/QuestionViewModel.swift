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
    var quizID: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    lazy var dataSource = OptionDataSource.dataSource()
    var displayQuestionString: BehaviorRelay<String> = BehaviorRelay(value: "")
    var displayOptions: BehaviorRelay<[OptionSection]> = BehaviorRelay(value: [])
    var isAnswerHidden: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    
    var didAnswerHandler: ((_ id: String, _ isCorrect: Bool) -> Void)?
    var didTapContinueHandler: (() -> Void)?
    var didTapDetailPageHandler: ((_ config: EntryDetailViewModel.Config) -> Void)?
    
    init() {
        self.quizID
            .asObservable()
            .subscribe(onNext: { value in
                if value != "" {
                    FirebaseDataSource.shared.fetch(Quiz.self, for: value) { result in
                        switch result {
                        case .failure(let error):
                            print(error)
                        case .success(let quiz):
                            self.quiz.accept(quiz)
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
                    self.displayOptions.accept([OptionSection(header: "", items: value.options)])
                    self.isAnswerHidden.accept(true)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension QuestionViewModel {
    var displayNextButtonString: String { return "Next" }
    var displayMasterButtonString: String { return "I mastered this question already" }
    var questionType: QuizType? { return quiz.value?.type }
}

// MARK: - DidSelectOptions
extension QuestionViewModel {
    private func revealAnswerInCells(with option: QuizOption, at indexPath: IndexPath) {
        guard let options = quiz.value?.options else { return }
        
        var newOptions = [QuizOption]()
        for (i, item) in options.enumerated() {
            var option = item
            option.state = (i == indexPath.row || item.isAnswer) ? .selected : .unselected
            newOptions.append(option)
        }
        self.displayOptions.accept([OptionSection(header: "", items: newOptions)])
    }
    func didSelect(_ option: QuizOption, at indexPath: IndexPath) {
        switch option.state {
        case .empty:
            self.didAnswerHandler?(quizID.value, option.isAnswer)
            self.revealAnswerInCells(with: option, at: indexPath)
            self.isAnswerHidden.accept(false)
        case .selected, .unselected:
            guard let questionType = questionType else { return }
            self.didTapDetailPageHandler?(EntryDetailViewModel.Config(id: option.linkedEntryId, type: questionType))
        }
    }
}

// MARK: - Actions after question answered
extension QuestionViewModel {
    func didRequestGoNextQuestion() {
        self.didTapContinueHandler?()
    }
    func didRequestBookmarkQuestion() {

    }
    func didRequestMasterQuestion() {
        FirebaseDataSource.shared.markQuestionAsMastered(for: quizID.value) { result in
            switch result {
            case .success:
                return
            case .failure(let error):
                print(error)
            }
        }
    }
}
