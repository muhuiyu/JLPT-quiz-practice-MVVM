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
    
    var isAnswered: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var selectedOptionEntryID: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    
    var displayNextButtonString: String { return "Next" }
    var displayMasterButtonString: String { return "I mastered this question already" }
    
    init() {
        self.quizID
            .asObservable()
            .subscribe(onNext: { value in
                if value != "" {
                    FirebaseDataSource.shared.fetchQuiz(atID: value) { quiz, error in
                        if let error = error {
                            print(error)
                            return
                        }
                        self.quiz.accept(quiz)
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
//    @objc
//    func didRequestRevealDetails(for entryID: String) -> Void {
//        print(entryID)
//        self.selectedOptionEntryID.accept(entryID)
//    }
    
    func didSelect(_ option: QuizOption) {
        self.isAnswered.accept(true)
        
        if option.isAnswer {
            
        } else {
            
        }
    }
    
    func didRequestGoNextQuestion() {

    }
    func didRequestBookmarkQuestion() {

    }
    func didRequestMasterQuestion() {
        
    }
}

