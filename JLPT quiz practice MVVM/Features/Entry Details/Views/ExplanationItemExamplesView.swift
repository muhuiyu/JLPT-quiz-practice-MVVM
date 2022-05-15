//
//  ExplanationItemExamplesView.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/14/22.
//

import UIKit

class ExplanationItemExamplesView: UIView {
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    var content: [String] = [] {
        didSet {
            reconfigureViews()
        }
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
extension ExplanationItemExamplesView {
    private func configureViews() {
        titleLabel.font = UIFont.bodyHeavy
        titleLabel.textColor = UIColor.label
        stackView.addArrangedSubview(titleLabel)
        stackView.axis = .vertical
        stackView.spacing = Constants.spacing.medium
        stackView.alignment = .leading
        addSubview(stackView)
    }
    private func reconfigureViews() {
        for example in content {
            let exampleLabel = UILabel()
            exampleLabel.font = UIFont.body
            exampleLabel.numberOfLines = 0
            exampleLabel.textColor = UIColor.label
            exampleLabel.text = example
            stackView.addArrangedSubview(exampleLabel)
        }
    }
    private func configureGestures() {
        
    }
    private func configureConstraints() {
        stackView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
