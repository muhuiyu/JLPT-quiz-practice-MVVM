//
//  SessionViewController.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import UIKit
import RxSwift

class SessionViewController: ViewController {
    private let disposeBag = DisposeBag()
    
    var viewModel = SessionViewModel()
    
    private let spinnerView = SpinnerView()
    private let headerContainer = UIView()
    private let headerProgressBar = ProgressBarView(frame: .zero, percentage: 0)
    private let sessionTitleLabel = UILabel()
    private let dismissButton = RoundButton(icon: UIImage(systemName: "xmark")!,
                                            buttonColor: UIColor.clear,
                                            iconColor: UIColor.secondaryLabel)
    private let pageControllerContainer = UIView()
    private let pageController = UIPageViewController(transitionStyle: .scroll,
                                                      navigationOrientation: .horizontal,
                                                      options: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureGestures()
        configureSignals()
        
        viewModel.currentIndex.accept(0)
    }
}
// MARK: - Actions
extension SessionViewController {
//    private func calculateProgress() -> Double {
//        return Double(Double(viewModel.currentIndex + 1)/Double(self.entry.count))
//    }
    private func didTapDismiss() {
        
    }
}
// MARK: - Navigation
extension SessionViewController {
    // TODO: update title label, configure header progress bar
    private func updateCurrentPage() {
        // configure viewcontroller and set page controller
        let viewController = viewModel.questionViewController()
        self.pageController.setViewControllers([viewController], direction: .forward, animated: true)
    }
}
// MARK: - View Config
extension SessionViewController {
    private func configureLoadingViews() {
        view.addSubview(spinnerView)
        spinnerView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    private func configureViews() {
        spinnerView.isHidden = true
        headerContainer.addSubview(headerProgressBar)
        
        sessionTitleLabel.text = "\(viewModel.displaySessionTitle) \(viewModel.currentIndex.value + 1)/\(viewModel.quizIDs.value.count)"
        sessionTitleLabel.font = UIFont.small
        sessionTitleLabel.textColor = UIColor.secondaryLabel
        
        headerContainer.addSubview(sessionTitleLabel)
        view.addSubview(headerContainer)
        
        dismissButton.tapHandler = {[weak self] in
            self?.didTapDismiss()
        }
        view.addSubview(dismissButton)

        addChild(pageController)
        pageController.didMove(toParent: self)
        view.addSubview(pageController.view)
    }
    private func configureConstraints() {
        headerProgressBar.snp.remakeConstraints { make in
            make.top.equalTo(headerContainer.layoutMarginsGuide).inset(Constants.spacing.small)
            make.leading.trailing.equalTo(headerContainer.layoutMarginsGuide).inset(Constants.spacing.medium)
        }
        sessionTitleLabel.snp.remakeConstraints { make in
            make.top.equalTo(headerProgressBar.snp.bottom).offset(Constants.spacing.medium)
            make.leading.equalTo(headerProgressBar)
            make.bottom.equalToSuperview()
        }
        dismissButton.snp.remakeConstraints { make in
            make.top.equalTo(view.layoutMarginsGuide).offset(Constants.spacing.enormous)
            make.trailing.equalTo(view.layoutMarginsGuide)
            make.size.equalTo(Constants.iconButtonSize.medium)
        }
        headerContainer.snp.remakeConstraints { make in
            make.top.equalTo(view.layoutMarginsGuide).offset(Constants.spacing.small)
            make.leading.trailing.equalToSuperview()
        }
        pageController.view.snp.remakeConstraints { make in
            make.top.equalTo(headerContainer.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    private func configureGestures() {
        
    }
    private func configureSignals() {
        viewModel.currentIndex
            .asObservable()
            .subscribe(onNext: { value in
                self.updateCurrentPage()
            })
            .disposed(by: disposeBag)
    }
}
