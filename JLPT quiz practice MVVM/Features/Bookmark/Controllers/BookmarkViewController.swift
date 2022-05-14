//
//  BookmarkViewController.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/14/22.
//

import UIKit
import RxSwift

class BookmarkViewController: ViewController {
    private let disposeBag = DisposeBag()
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()

    var viewModel = BookmarkViewModel()
    
    override init() {
        super.init()
        tabBarItem = viewModel.tabBarItem
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureSignals()
    }
}
// MARK: - Actions
extension BookmarkViewController {
    @objc
    private func refreshTableView(_ sender: Any) {
        viewModel.fetchBookmarks { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                self.refreshControl.endRefreshing()
            }
        }
    }
}
// MARK: - View Config
extension BookmarkViewController {
    private func configureViews() {
        navigationItem.title = viewModel.titleString
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshTableView(_:)), for: .valueChanged)
        tableView.register(BookmarkCell.self, forCellReuseIdentifier: BookmarkCell.reuseID)
        view.addSubview(tableView)
    }
    private func configureConstraints() {
        tableView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    private func configureSignals() {
        viewModel.displayBookmarks
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
    }
}
