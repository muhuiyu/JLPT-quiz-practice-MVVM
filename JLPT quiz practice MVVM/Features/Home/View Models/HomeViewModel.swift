//
//  HomeViewModel.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 4/26/22.
//

import Foundation
import RxRelay
import UIKit

class HomeViewModel {
    
    struct CellContent {
        let title: String
        let options: [String]
    }
    
    var quizConfigValues: [CellContent] = [
        CellContent(title: "type", options: ["mixed", "grammar", "vocab", "kanji"]),
        CellContent(title: "level", options: ["all", "n1", "n2"]),
        CellContent(title: "number of questions", options: ["10", "15", "20"]),
    ]
    
}

extension HomeViewModel {
    var titleString: String { return "JLPT quiz" }
    var displayButtonTextString: String { return "Start" }
    var displayQuizConfigActionSheetTitleString: String { return "Choose" }
    var displayQuizConfigActionSheetMessageString: String { return "" }
    var tabBarItem: UITabBarItem { return UITabBarItem(title: titleString,
                                                       image: UIImage(systemName: "house"),
                                                       selectedImage: UIImage(systemName: "house.fill")) }
}

extension HomeViewModel {
    func getSessionViewController(with configuration: QuizConfig, completion: @escaping (Result<SessionViewController, Error>) -> Void) {
        let viewController = SessionViewController()
        FirebaseDataSource.shared.generateQuizList(with: configuration) { result in
            switch result {
            case .success(let quizIDs):
                viewController.viewModel.quizIDs.accept(quizIDs)
                return completion(.success(viewController))
            case .failure(let error):
                return completion(.failure(error))
            }
        }
    }
}
