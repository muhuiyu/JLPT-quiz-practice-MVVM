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
    var quizConfigValues: [QuizConfig] = [
        QuizConfig(item: "type", options: ["grammar", "vocab"]),
        QuizConfig(item: "level", options: ["n1", "n2"]),
    ]
    
    struct QuizConfig {
        let item: String
        let options: [String]
    }
}

extension HomeViewModel {
    var displayTitleString: String { return "JLPT quiz" }
    var displayButtonTextString: String { return "Start" }
    var displayTabTitleString: String { return "Home" }
    var displayTabImage: UIImage? { return UIImage(systemName: "house") }
    var displayTabSelectedImage: UIImage? { return UIImage(systemName: "house.fill") }
    var displayQuizConfigActionSheetTitle: String { return "Choose" }
    var displayQuizConfigActionSheetMessage: String { return "" }
}

extension HomeViewModel {
    func getQuizViewController(with configurations: [QuizConfig]) -> SessionViewController {
        print(configurations)
        
        let testID = ["006kVLwsfIdiarQ5Oxjs", "00leEbKUh7x2wqP2e0ng", "04eB4pBPaI5I8M1zrhHD"]
        let viewModel = SessionViewModel()
        viewModel.quizIDs.accept(testID)
        let viewController = SessionViewController()
        viewController.viewModel = viewModel
        
        return viewController
    }
}
