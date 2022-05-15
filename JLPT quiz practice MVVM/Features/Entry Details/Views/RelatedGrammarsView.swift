//
//  RelatedGrammarsView.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/14/22.
//

import UIKit

protocol RelatedGrammarsViewDelegate: AnyObject {
    func relatedGrammarsView(_ view: RelatedGrammarsView, didTapInGrammar id: String)
}

class RelatedGrammarsView: UIView {
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    var content: [RelatedGrammarItem] = [] {
        didSet {
            reconfigureViews()
        }
    }
    struct RelatedGrammarItem {
        let id: String
        let title: String
    }
    
    weak var delegate: RelatedGrammarsViewDelegate?
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
// MARK: - Actions
extension RelatedGrammarsView {
    private func didTapInGrammar(at id: String) {
        delegate?.relatedGrammarsView(self, didTapInGrammar: id)
    }
}
// MARK: - View Config
extension RelatedGrammarsView {
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
        for grammar in content {
            let grammarItemView = RelatedGrammarItemView()
            grammarItemView.title = grammar.title
            grammarItemView.tapHandler = {[weak self] in
                self?.didTapInGrammar(at: grammar.id)
            }
            stackView.addArrangedSubview(grammarItemView)
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
