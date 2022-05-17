//
//  HomeViewController.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import UIKit
import RxSwift
import RxDataSources

class HomeViewController: ViewController {
    private let tableView = UITableView()
    private let startButton = TextButton()
    private let spinnerView = SpinnerView()
    
    var viewModel = HomeViewModel()

    override init() {
        super.init()
        tabBarItem = viewModel.tabBarItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureLoadingViews()
    }
}

// MARK: - Actions
extension HomeViewController {
    @objc
    private func didTapStart() {
        spinnerView.isHidden = false
        guard let cells = tableView.visibleCells as? [QuizConfigCell] else { return }
        
        var type: QuizType = .mixed
        var level: QuizLevel = .all
        var numberOfQuestions = 10
        
        for cell in cells {
            let title = cell.viewModel.config.value.title
            guard let value = cell.viewModel.selectedValue.value else { continue }
            
            switch title {
            case "level":
                level = QuizLevel(rawValue: value) ?? .all
            case "type":
                type = QuizType(rawValue: value) ?? .mixed
            case "number of questions":
                numberOfQuestions = Int(value) ?? 10
            default: continue
            }
        }
        
        let config = QuizConfig(type: type, level: level, numberOfQuestions: numberOfQuestions)
        viewModel.getSessionViewController(with: config) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let viewController):
                viewController.isModalInPresentation = true
                self.spinnerView.isHidden = true
                self.present(viewController.embedInNavgationController(), animated: true)
            }
        }
    }
}

// MARK: - View Config
extension HomeViewController {
    private func configureLoadingViews() {
        spinnerView.isHidden = true
        view.addSubview(spinnerView)
        spinnerView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    private func configureViews() {
        title = viewModel.titleString
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(QuizConfigCell.self, forCellReuseIdentifier: QuizConfigCell.reuseID)
        view.addSubview(tableView)
        
        startButton.text = viewModel.displayButtonTextString
        startButton.tapHandler = { [weak self] in
            self?.didTapStart()
        }
        view.addSubview(startButton)
    }
    private func configureConstraints() {
        tableView.snp.remakeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        startButton.snp.remakeConstraints { make in
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
            make.bottom.equalTo(view.layoutMarginsGuide).inset(Constants.spacing.medium)
        }
    }
}

// MARK: - Data Source
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.quizConfigValues.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: QuizConfigCell.reuseID) as? QuizConfigCell else { return UITableViewCell() }
        cell.viewModel.config.accept(viewModel.quizConfigValues[indexPath.row])
        return cell
    }
}
// MARK: - Delegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        guard let cell = tableView.cellForRow(at: indexPath) as? QuizConfigCell else { return }
        let alert = UIAlertController(title: viewModel.displayQuizConfigActionSheetTitleString,
                                      message: viewModel.displayQuizConfigActionSheetMessageString,
                                      preferredStyle: .actionSheet)
        for option in cell.options {
            alert.addAction(UIAlertAction(title: option, style: .default, handler: { value in
                cell.viewModel.selectedValue.accept(value.title)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
}

