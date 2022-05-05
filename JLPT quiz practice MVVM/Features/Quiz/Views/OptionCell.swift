//
//  OptionCell.swift
//  Fun with Flags
//
//  Created by Mu Yu on 15/5/21.
//

import UIKit

class OptionCell: UITableViewCell {
    static let reuseID = NSStringFromClass(OptionCell.self)
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let buttonLabel = UILabel()
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var status: OptionCellStatus = .none {
        didSet {
            reconfigureViews()
        }
    }
    var buttonTapHandler: (() -> Void)?
    var isButtonHidden: Bool = true {
        didSet {
            buttonLabel.isHidden = isButtonHidden
        }
    }

    enum OptionCellStatus {
        case none
        case correct
        case wrong
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
        configureGestures()
        configureConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - Actions
extension OptionCell {
    @objc
    private func didTapButton() {
        self.buttonTapHandler?()
    }
}
// MARK: - View Config
extension OptionCell {
    private func configureViews() {
        titleLabel.textColor = UIColor.label
        titleLabel.font = UIFont.body
//        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        containerView.addSubview(titleLabel)
        
        buttonLabel.isUserInteractionEnabled = true
        buttonLabel.font = UIFont.desc
        buttonLabel.textColor = UIColor.label
        buttonLabel.text = "View More"
        buttonLabel.isHidden = self.isButtonHidden
        containerView.addSubview(buttonLabel)
        
        containerView.layer.cornerRadius = Constants.card.cornerRadius
        containerView.backgroundColor = UIColor.secondarySystemBackground
        contentView.addSubview(containerView)
    }
    private func reconfigureViews() {
        switch status {
        case .none: containerView.backgroundColor = UIColor.secondarySystemBackground
        case .correct: containerView.backgroundColor = UIColor.optionCell.correct
        case .wrong: containerView.backgroundColor = UIColor.optionCell.wrong
        }
    }

    private func configureGestures() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapButton))
        buttonLabel.addGestureRecognizer(tapRecognizer)
    }
    private func configureConstraints() {
        titleLabel.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(Constants.spacing.medium)
            make.trailing.equalTo(buttonLabel.snp.leading).offset(-Constants.spacing.small)
        }
        buttonLabel.snp.remakeConstraints { make in
            make.trailing.equalToSuperview().inset(Constants.spacing.medium)
            make.centerY.equalTo(titleLabel)
        }
        containerView.snp.remakeConstraints { make in
            make.edges.equalTo(contentView.layoutMarginsGuide)
            make.height.equalTo(50)
        }
    }
}
