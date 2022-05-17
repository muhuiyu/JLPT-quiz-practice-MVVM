//
//  OptionCell.swift
//  Fun with Flags
//
//  Created by Mu Yu on 15/5/21.
//

import UIKit
import RxSwift

class OptionCell: UITableViewCell {
    private let disposeBag = DisposeBag()
    static let reuseID = NSStringFromClass(OptionCell.self)
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let buttonLabel = UILabel()
    
    var viewModel = OptionCellViewModel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
        configureConstraints()
        configureSignals()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - View Config
extension OptionCell {
    private func configureViews() {
        titleLabel.text = "default"
        titleLabel.textColor = UIColor.label
        titleLabel.font = UIFont.body
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        containerView.addSubview(titleLabel)
        
        buttonLabel.isUserInteractionEnabled = true
        buttonLabel.font = UIFont.desc
        buttonLabel.textColor = UIColor.label
        buttonLabel.text = viewModel.displayButtonString
        buttonLabel.isHidden = true
        containerView.addSubview(buttonLabel)
        
        containerView.layer.cornerRadius = Constants.card.cornerRadius
        containerView.backgroundColor = UIColor.secondarySystemBackground
        contentView.addSubview(containerView)
    }
    private func reconfigureViews(as state: QuizOption.State, isOptionAnswer: Bool) {
        switch state {
        case .empty:
            containerView.backgroundColor = UIColor.secondarySystemBackground
            buttonLabel.isHidden = true
        case .selected:
            containerView.backgroundColor = isOptionAnswer ? UIColor.optionCell.correct : UIColor.optionCell.wrong
            buttonLabel.isHidden = !viewModel.isLinkedEntryIdValid
        case .unselected:
            containerView.backgroundColor = UIColor.secondarySystemBackground
            buttonLabel.isHidden = !viewModel.isLinkedEntryIdValid
        }
    }
    private func configureConstraints() {
        titleLabel.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview().inset(Constants.spacing.medium)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(Constants.spacing.medium)
        }
        buttonLabel.snp.remakeConstraints { make in
            make.trailing.equalToSuperview().inset(Constants.spacing.medium)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(-Constants.spacing.medium)
            make.centerY.equalTo(titleLabel)
        }
        containerView.snp.remakeConstraints { make in
            make.edges.equalTo(contentView.layoutMarginsGuide)
        }
    }
    private func configureSignals() {
        viewModel.displayTitle
            .asObservable()
            .subscribe(onNext: { value in
                self.titleLabel.text = value
            })
            .disposed(by: disposeBag)
        
        viewModel.state
            .asObservable()
            .subscribe(onNext: { value in
                self.reconfigureViews(as: value, isOptionAnswer: self.viewModel.option.value?.isAnswer ?? false)
            })
            .disposed(by: disposeBag)
    }
}
