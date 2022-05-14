//
//  QuestionViewController.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/5/22.
//

import UIKit
import AVFoundation
import RxSwift

class QuestionViewController: ViewController {
    private let disposeBag = DisposeBag()
    
    private let spinnerView = SpinnerView()
    
    private let questionLabel = UILabel()
    private let tableView = UITableView()
    private let masteredButton = TextButton(frame: .zero, buttonType: .text)
    private let nextButton = TextButton(frame: .zero, buttonType: .primary)
    private var answerSoundEffect: AVAudioPlayer?
    
    var viewModel = QuestionViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureSignals()
    }
}
// MARK: - Action
extension QuestionViewController {
    private func displayFeedback(isCorrect: Bool) {
        self.nextButton.isHidden = false
        self.masteredButton.isHidden = false
        
        // 1. highlight selected item
        guard
            let selectedOptionIndexPath = viewModel.selectionOptionIndexPath,
            let selectedCell = self.tableView.cellForRow(at: selectedOptionIndexPath) as? OptionCell
        else { return }
        selectedCell.viewModel.isAnswerRevealed.accept(true)
        
        // 2. highlight correct answer
        if !isCorrect {
            if let cells = self.tableView.visibleCells as? [OptionCell] {
                for cell in cells {
                    guard let option = cell.viewModel.option.value else { continue }
                    if option.isAnswer { cell.viewModel.isAnswerRevealed.accept(true) }
                }
            }
        }
        
        // 3. play sound
        let soundFileName = isCorrect ? "correct.m4a" : "wrong.m4a"
        guard let path = Bundle.main.path(forResource: soundFileName, ofType: nil) else { return }
        let url = URL(fileURLWithPath: path)
        do {
            answerSoundEffect = try AVAudioPlayer(contentsOf: url)
            answerSoundEffect?.play()
        } catch {
            print(error)
        }
    }
}
// MARK: - View Config
extension QuestionViewController {
    private func configureViews() {
        spinnerView.isHidden = false
        view.addSubview(spinnerView)
        
        questionLabel.font = UIFont.body
        questionLabel.textColor = UIColor.label
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .left
        view.addSubview(questionLabel)
        
        tableView.register(OptionCell.self, forCellReuseIdentifier: OptionCell.reuseID)
        tableView.tableFooterView = UIView()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        view.addSubview(tableView)
        
        nextButton.tapHandler = viewModel.didRequestGoNextQuestion
        nextButton.text = viewModel.displayNextButtonString
        nextButton.isHidden = true
        view.addSubview(nextButton)
        
        masteredButton.tapHandler = viewModel.didRequestMasterQuestion
        masteredButton.text = viewModel.displayMasterButtonString
        masteredButton.isHidden = true
        view.addSubview(masteredButton)
    }
    private func configureConstraints() {
        spinnerView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
        questionLabel.snp.remakeConstraints { make in
            make.top.equalTo(view.layoutMarginsGuide).inset(Constants.spacing.enormous)
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
        }
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(questionLabel.snp.bottom).offset(Constants.spacing.enormous)
            make.leading.trailing.bottom.equalToSuperview()
        }
        nextButton.snp.remakeConstraints { make in
            make.leading.trailing.equalTo(masteredButton)
            make.bottom.equalTo(masteredButton.snp.top).offset(-Constants.spacing.small)
        }
        masteredButton.snp.remakeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.layoutMarginsGuide)
        }
    }
    private func configureSignals() {
        viewModel.displayQuestionString
            .asObservable()
            .subscribe(onNext: { value in
                self.questionLabel.text = value
            })
            .disposed(by: disposeBag)
        
        viewModel.displayOptions
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
        
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(QuizOption.self))
            .subscribe { indexPath, item in
                self.viewModel.didSelect(item, at: indexPath)
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)
        
        viewModel.state
            .asObservable()
            .subscribe(onNext: { state in
                switch state {
                case .loading:
                    self.spinnerView.isHidden = false
                case .unanswered:
                    self.spinnerView.isHidden = true
                case .answeredCorrectly:
                    self.displayFeedback(isCorrect: true)
                case .answeredWrongly:
                    self.displayFeedback(isCorrect: false)
                case .didReqestExplanation:
                    return
                default:
                    return
                }
            })
            .disposed(by: disposeBag)
    }
}
