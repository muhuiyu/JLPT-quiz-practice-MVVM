//
//  ExplanationItemView.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/14/22.
//

import UIKit

class ExplanationItemView: UIView {
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    var content: String? {
        get { return contentLabel.text }
        set { contentLabel.text = newValue }
    }
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        configureViews()
        configureGestures()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - View Config
extension ExplanationItemView {
    private func configureViews() {
        titleLabel.font = UIFont.bodyHeavy
        titleLabel.textColor = UIColor.label
        stackView.addArrangedSubview(titleLabel)
        contentLabel.font = UIFont.body
        contentLabel.textColor = UIColor.label
        contentLabel.numberOfLines = 0
        stackView.addArrangedSubview(contentLabel)
        stackView.axis = .vertical
        stackView.spacing = Constants.spacing.medium
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        addSubview(stackView)
    }
    private func configureGestures() {
        
    }
    private func configureConstraints() {
        stackView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
