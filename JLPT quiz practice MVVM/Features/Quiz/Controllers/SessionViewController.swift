//
//  SessionViewController.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import UIKit
import AVFoundation
import RxSwift

class SessionViewController: ViewController {
    private let disposeBag = DisposeBag()
    
    var viewModel = SessionViewModel()
    
    private let headerContainer = UIView()
    private let headerProgressBar = ProgressBarView(frame: .zero, percentage: 0)
    private let sessionTitleLabel = UILabel()
    private let dismissButton = RoundButton(icon: UIImage(systemName: "xmark"),
                                            buttonColor: UIColor.clear,
                                            iconColor: UIColor.secondaryLabel)
    private let pageControllerContainer = UIView()
    private let pageController = UIPageViewController(transitionStyle: .scroll,
                                                      navigationOrientation: .horizontal,
                                                      options: nil)
    
    private var answerSoundEffect: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureSignals()
    }
}
// MARK: - Navigation
extension SessionViewController {
    private func endSession() {
        self.dismiss(animated: true)
    }
    private func updateCurrentPage() {
        let viewController = viewModel.questionViewController
        viewController.viewModel.didTapDetailPageHandler = { [weak self] config in
            self?.displayDetailViewController(for: config.id, as: config.type)
        }
        self.headerProgressBar.updateProgressBar(to: viewModel.currentProgress)
        self.pageController.setViewControllers([viewController], direction: .forward, animated: true)
    }
    private func presentOptionEntryNotFoundAlert() {
        
    }
    private func displayDetailViewController(for id: String, as type: QuizType) {
        guard !id.isEmpty else {
            self.present(viewModel.optionEntryNotFoundAlert, animated: true, completion: nil)
            return
        }
        let viewController = EntryDetailViewController()
        viewController.viewModel.entryConfig.accept(EntryDetailViewModel.Config(id: id, type: type))
        navigationController?.pushViewController(viewController, animated: true)
    }
    private func presentSessionSummaryAlert() {
        self.present(viewModel.sessionSummaryAlert, animated: true, completion: nil)
    }
    private func didTapDismiss() {
        viewModel.state.accept(.sessionEnded)
    }
}
// MARK: - Sound
extension SessionViewController {
    func playSound(isCorrect: Bool) {
        let soundFileName = viewModel.getSoundFileName(isCorrect: isCorrect)
        guard let path = Bundle.main.path(forResource: soundFileName, ofType: nil) else { return }
        let url = URL(fileURLWithPath: path)
        do {
            answerSoundEffect = try AVAudioPlayer(contentsOf: url)
            answerSoundEffect?.play()
        } catch {
            print(error)
        }
    }
}
// MARK: - View Config
extension SessionViewController {
    private func configureViews() {
        navigationItem.largeTitleDisplayMode = .never
        
        headerContainer.addSubview(headerProgressBar)
        
        sessionTitleLabel.text = viewModel.displaySessionTitleString
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
    private func configureSignals() {
        viewModel.state
            .asObservable()
            .subscribe(onNext: { status in
                switch status {
                case .questionLoaded:
                    self.updateCurrentPage()
                case .answered(let isCorrect):
                    self.playSound(isCorrect: isCorrect)
                case .sessionSummaryPresented:
                    self.presentSessionSummaryAlert()
                case .sessionEnded:
                    self.endSession()
                }
            })
            .disposed(by: disposeBag)
    }
}
