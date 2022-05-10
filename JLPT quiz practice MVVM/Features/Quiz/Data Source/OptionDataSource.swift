//
//  OptionDataSource.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/5/22.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct OptionDataSource {
    typealias DataSource = RxTableViewSectionedReloadDataSource

    static func dataSource(_ viewModel: QuestionViewModel) -> DataSource<OptionSection> {
        return DataSource<OptionSection>(
            configureCell: { dataSource, tableView, indexPath, item -> UITableViewCell in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: OptionCell.reuseID, for: indexPath) as? OptionCell else {
                    return UITableViewCell()
                }
                cell.viewModel.option.accept(item)
                return cell

            }, titleForHeaderInSection: { dataSource, index in
                return dataSource.sectionModels[index].header
            }
        )
    }
}

