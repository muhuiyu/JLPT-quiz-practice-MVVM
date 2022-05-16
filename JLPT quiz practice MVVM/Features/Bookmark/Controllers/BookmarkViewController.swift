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
    private func didSelect(_ item: Bookmark) {
        let viewController = self.viewModel.entryDetailViewController(for: item)
        self.navigationController?.pushViewController(viewController, animated: true)
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
        
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(BookmarkItem.self))
            .subscribe { indexPath, item in
                self.didSelect(item.bookmark)
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)
    }
}
