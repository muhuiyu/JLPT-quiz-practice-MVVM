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
    
    var viewModel = HomeViewModel()
        
    override init() {
        super.init()
        tabBarItem = UITabBarItem(title: viewModel.displayTabTitleString,
                                  image: viewModel.displayTabImage,
                                  selectedImage: viewModel.displayTabSelectedImage)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureGestures()
        configureSignals()
    }
}

// MARK: - Actions
extension HomeViewController {
    @objc
    private func didTapStart() {
        guard let cells = tableView.visibleCells as? [QuizConfigCell] else { return }
        let configs = cells.map { $0.viewModel.config.value }
        let viewController = viewModel.getQuizViewController(with: configs)
        viewController.isModalInPresentation = true
        self.present(viewController.embedInNavgationController(), animated: true)
    }
}

// MARK: - View Config
extension HomeViewController {
    private func configureViews() {
        title = viewModel.displayTitleString
        
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
            make.leading.trailing.bottom.equalTo(view.layoutMarginsGuide)
        }
    }
    private func configureGestures() {
        
    }
    private func configureSignals() {
        
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
        let alert = UIAlertController(title: viewModel.displayQuizConfigActionSheetTitle,
                                      message: viewModel.displayQuizConfigActionSheetMessage,
                                      preferredStyle: .actionSheet)
        for option in cell.options {
            alert.addAction(UIAlertAction(title: option, style: .default, handler: { value in
                cell.viewModel.selectedValue.accept(value.title)
            }))
        }
        self.present(alert, animated: true)
    }
}

