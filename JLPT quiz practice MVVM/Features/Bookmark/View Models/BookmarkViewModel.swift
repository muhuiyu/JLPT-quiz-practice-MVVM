//
//  BookmarkViewModel.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/14/22.
//

import UIKit
import RxSwift
import RxRelay
import RxDataSources

class BookmarkViewModel {
    private let disposeBag = DisposeBag()
    
    var bookmarks: BehaviorRelay<[Bookmark]> = BehaviorRelay(value: [])
    var displayBookmarks: BehaviorRelay<[BookmarkSection]> = BehaviorRelay(value: [])
    lazy var dataSource = BookmarkDataSource.dataSource()
    
    init() {
        fetchBookmarks { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                break
            }
        }
        self.bookmarks
            .asObservable()
            .subscribe(onNext: { value in
                let ids = value.map { BookmarkItem(bookmark: $0) }
                self.displayBookmarks.accept([BookmarkSection(header: "", items: ids)])
            })
            .disposed(by: disposeBag)
    }
}

extension BookmarkViewModel {
    var titleString: String { return "Bookmark" }
    var tabBarItem: UITabBarItem { return UITabBarItem(title: titleString,
                                                       image: UIImage(systemName: "bookmark"),
                                                       selectedImage: UIImage(systemName: "bookmark.fill")) }
}

extension BookmarkViewModel {
    func fetchBookmarks(completion: @escaping (VoidResult) -> Void) {
        FirebaseDataSource.shared.fetchBookmarks(for: .mixed) { result in
            switch result {
            case .failure(let error):
                return completion(.failure(error))
            case .success(let items):
                self.bookmarks.accept(items)
                return completion(.success)
            }
        }
    }
    func deleteItem(for id: String) {
        FirebaseDataSource.shared.removeBookmark(for: id) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success:
                var items = self.bookmarks.value
                if let index = items.firstIndex(where: { $0.id == id }) {
                    items.remove(at: index)
                }
                self.bookmarks.accept(items)
            }
        }
    }
}
