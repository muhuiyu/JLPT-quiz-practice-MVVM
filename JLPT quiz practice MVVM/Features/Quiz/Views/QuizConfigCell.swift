//
//  QuizConfigCell.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import UIKit
import RxSwift

class QuizConfigCell: UITableViewCell {
    static let reuseID = NSStringFromClass(QuizConfigCell.self)
    
    private let disposeBag = DisposeBag()
    
    var viewModel = QuizConfigViewModel()
    
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    
    var options: [String] = []
    
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
// MARK: - View Config
extension QuizConfigCell {
    private func configureViews() {
        titleLabel.font = UIFont.body
        titleLabel.textColor = .label
        titleLabel.textAlignment = .left
        contentView.addSubview(titleLabel)
        
        valueLabel.font = UIFont.body
        valueLabel.textColor = .secondaryLabel
        valueLabel.textAlignment = .right
        contentView.addSubview(valueLabel)
    }
    private func configureConstraints() {
        titleLabel.snp.remakeConstraints { make in
            make.leading.equalTo(contentView.layoutMarginsGuide)
            make.top.bottom.equalTo(contentView.layoutMarginsGuide)
        }
        valueLabel.snp.remakeConstraints { make in
            make.top.bottom.equalTo(titleLabel)
            make.trailing.equalTo(contentView.layoutMarginsGuide)
        }
    }
    private func configureGestures() {
        
    }
    private func configureSignals() {
        viewModel
            .config
            .asObservable()
            .subscribe(onNext: { value in
                self.titleLabel.text = value.item
                self.options = value.options
            })
            .disposed(by: disposeBag)
        
        viewModel
            .selectedValue
            .asObservable()
            .subscribe(onNext: { value in
                self.valueLabel.text = value
            })
            .disposed(by: disposeBag)
    }
}
