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
        configureGestures()
        configureSignals()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - Actions
extension OptionCell {
    @objc
    private func didTapButton() {
        viewModel.buttonTapHandler?()
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
    private func reconfigureViews(isAnswerRevealed: Bool, isOptionAnswer: Bool) {
        if isAnswerRevealed {
            containerView.backgroundColor = isOptionAnswer ? UIColor.optionCell.correct : UIColor.optionCell.wrong
            buttonLabel.isHidden = false
        } else {
            containerView.backgroundColor = UIColor.secondarySystemBackground
            buttonLabel.isHidden = true
        }
    }

    private func configureGestures() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapButton))
        buttonLabel.addGestureRecognizer(tapRecognizer)
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
        
        viewModel.isAnswerRevealed
            .asObservable()
            .subscribe(onNext: { value in
                self.reconfigureViews(isAnswerRevealed: value, isOptionAnswer: self.viewModel.option.value?.isAnswer ?? false)
            })
            .disposed(by: disposeBag)
    }
}
