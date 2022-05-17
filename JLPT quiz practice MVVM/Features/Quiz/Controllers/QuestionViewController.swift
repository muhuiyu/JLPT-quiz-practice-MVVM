//
//  QuestionViewController.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/5/22.
//

import UIKit
import RxSwift

class QuestionViewController: ViewController {
    private let disposeBag = DisposeBag()
    
    private let spinnerView = SpinnerView()
    
    private let questionLabel = UILabel()
    private let tableView = UITableView()
    private let masteredButton = TextButton(frame: .zero, buttonType: .text)
    private let nextButton = TextButton(frame: .zero, buttonType: .primary)
    
    var viewModel = QuestionViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureSignals()
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
        
        viewModel.isAnswerHidden
            .asObservable()
            .subscribe(onNext: { value in
                self.nextButton.isHidden = value
                self.masteredButton.isHidden = value
            })
            .disposed(by: disposeBag)
        
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(QuizOption.self))
            .subscribe { indexPath, item in
                self.viewModel.didSelect(item, at: indexPath)
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)
    }
}
