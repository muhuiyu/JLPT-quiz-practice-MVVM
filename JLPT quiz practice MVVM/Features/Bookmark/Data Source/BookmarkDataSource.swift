//
//  BookmarkDataSource.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/14/22.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct BookmarkDataSource {
    typealias DataSource = RxTableViewSectionedReloadDataSource

    static func dataSource() -> DataSource<BookmarkSection> {
        return DataSource<BookmarkSection>(
            configureCell: { dataSource, tableView, indexPath, item -> UITableViewCell in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkCell.reuseID, for: indexPath) as? BookmarkCell else {
                    return UITableViewCell()
                }
                cell.viewModel.bookmarkItem.accept(item)
                return cell

            }, titleForHeaderInSection: { dataSource, index in
                return dataSource.sectionModels[index].header
            }
        )
    }
}

