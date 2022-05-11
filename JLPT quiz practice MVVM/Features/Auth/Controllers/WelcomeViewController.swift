//
//  WelcomeViewController.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/10/22.
//


import UIKit
import Firebase

class WelcomeViewController: ViewController {
    private let titleView = UILabel()
    private let googleLoginButton = TextButton(frame: .zero, buttonType: .primary)
    
    var viewModel = WelcomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureSignals()
    }
}
// MARK: - Actions
extension WelcomeViewController {
    private func didTapGoogleLogin() {
        viewModel.state.accept(.requestLogin)
    }
}
// MARK: - View Config
extension WelcomeViewController {
    private func configureViews() {
        titleView.text = viewModel.displayTitleString
        titleView.font = UIFont.h2
        titleView.textColor = UIColor.label
        view.addSubview(titleView)
        
        googleLoginButton.tapHandler = {[weak self] in
            self?.didTapGoogleLogin()
        }
        googleLoginButton.text = viewModel.displayGoogleLoginButtonTextString
        view.addSubview(googleLoginButton)
    }
    private func configureConstraints() {
        titleView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
        googleLoginButton.snp.remakeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.layoutMarginsGuide)
        }
    }
    private func configureSignals() {
        
    }
}
