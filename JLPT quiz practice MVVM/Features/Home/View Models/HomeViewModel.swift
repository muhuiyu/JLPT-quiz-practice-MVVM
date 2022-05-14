//
//  HomeViewModel.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import Foundation
import RxRelay

class HomeViewModel {
    
    var title: String { return "JLPT quiz" }
    var displayButtonText: String { return "Start" }
    
    struct CellContent {
        let title: String
        let options: [String]
    }
    
    var quizConfigValues: [CellContent] = [
        CellContent(title: "type", options: ["mixed", "grammar", "vocab", "kanji"]),
        CellContent(title: "level", options: ["all", "n1", "n2"]),
        CellContent(title: "number of questions", options: ["10", "15", "20"]),
    ]
    
    var displayQuizConfigActionSheetTitle: String { return "Choose" }
    var displayQuizConfigActionSheetMessage: String { return "" }
}

extension HomeViewModel {
    func getQuizViewController(with configuration: QuizConfig, callback: @escaping (_ viewController: SessionViewController, _ error: Error?) -> Void) {
        let viewController = SessionViewController()
        FirebaseDataSource.shared.generateQuizList(with: configuration) { result in
            switch result {
            case .success(let quizIDs):
                viewController.viewModel.quizIDs.accept(quizIDs)
                return callback(viewController, nil)
            case .failure(let error):
                return callback(viewController, error)
            }
        }
    }
}
