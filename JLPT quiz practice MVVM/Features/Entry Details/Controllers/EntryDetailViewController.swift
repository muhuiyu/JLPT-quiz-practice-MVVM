//
//  EntryDetailViewController.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/14/22.
//

import UIKit
import RxSwift

class EntryDetailViewController: ViewController {
    private let disposeBag = DisposeBag()
    
    private let spinnerView = SpinnerView()
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let meaningView = ExplanationItemView()

    var viewModel = EntryDetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureSignals()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
// MARK: - View Config
extension EntryDetailViewController {
    private func configureBookmarkButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: viewModel.bookmarkItemImage,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(viewModel.didTapBookmark))
    }
    private func configureViews() {
        navigationItem.largeTitleDisplayMode = .never
        
        spinnerView.isHidden = true
        view.addSubview(spinnerView)
        
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.label
        titleLabel.font = UIFont.h2
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(meaningView)
        
        stackView.axis = .vertical
        stackView.spacing = Constants.spacing.large
        stackView.alignment = .leading
        containerView.addSubview(stackView)
        scrollView.addSubview(containerView)
        view.addSubview(scrollView)
    }
    private func configureContent() {
        titleLabel.text = viewModel.displayTitleLabelString
        meaningView.title = viewModel.displayMeaningLabelTitleString
        meaningView.content = viewModel.displayMeaningLabelContentString
        
        let type = viewModel.entryConfig.value.type
        if type == .grammar {
            self.configureGrammarStackView()
        }
    }
    private func configureGrammarStackView() {
        guard let entry = viewModel.entry.value as? Grammar else { return }
        let formationView = ExplanationItemView()
        let examplesStackView = ExplanationItemExamplesView()
        let relatedGrammarsView = RelatedGrammarsView()

        formationView.title = viewModel.displayGrammarFormationLabelTitleString
        formationView.content = entry.formation
        stackView.addArrangedSubview(formationView)
        
        examplesStackView.title = viewModel.displayGrammarExamplesStackViewTitleString
        examplesStackView.content = entry.examples
        stackView.addArrangedSubview(examplesStackView)
        
        if !entry.remark.isEmpty {
            let remarkView = ExplanationItemView()
            remarkView.title = viewModel.displayGrammarRemarkViewTitleString
            remarkView.content = entry.remark
            stackView.addArrangedSubview(remarkView)
        }
        if !entry.relatedGrammar.isEmpty {
            relatedGrammarsView.title = viewModel.displayGrammarRelatedGrammersViewTitleString
            viewModel.getGrammarItems(for: entry.relatedGrammar) { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let items):
                    // TODO: click related grammar item and navigate to EntryDetailViewController
                    relatedGrammarsView.content = items
                    self.stackView.addArrangedSubview(relatedGrammarsView)
                }
            }
        }
    }
    private func configureConstraints() {
        spinnerView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
        stackView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(Constants.spacing.medium)
        }
        containerView.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalTo(scrollView)
            make.bottom.equalToSuperview().inset(Constants.spacing.medium)
        }
        scrollView.snp.remakeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view.bounds.width)
        }
    }
    private func configureSignals() {
        viewModel.isBookmarked
            .asObservable()
            .subscribe(onNext: { _ in
                self.configureBookmarkButton()
            })
            .disposed(by: disposeBag)
        
        viewModel.entry
            .asObservable()
            .subscribe(onNext: { _ in
                self.configureContent()
            })
            .disposed(by: disposeBag)
    }
}
