//
//  BookmarkCell.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/14/22.
//

import UIKit
import RxSwift

class BookmarkCell: UITableViewCell {
    private let disposeBag = DisposeBag()
    static let reuseID = NSStringFromClass(BookmarkCell.self)
    
    private let titleLabel = UILabel()
    var viewModel = BookmarkCellViewModel()
    
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
extension BookmarkCell {
    private func configureViews() {
        titleLabel.text = "default"
        titleLabel.textColor = UIColor.label
        titleLabel.font = UIFont.body
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        contentView.addSubview(titleLabel)
    }
    private func configureConstraints() {
        titleLabel.snp.remakeConstraints { make in
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
    }
}
