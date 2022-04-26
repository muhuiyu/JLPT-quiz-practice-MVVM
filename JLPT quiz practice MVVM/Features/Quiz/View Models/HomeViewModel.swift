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
    private func getQuizViewModel(with configuration: [QuizConfig]) -> QuizViewModel {
        let viewModel = QuizViewModel()
        return viewModel
    }
    func getQuizViewController(with configuration: [QuizConfig]) -> QuizViewController {
        
        return QuizViewController()
    }
}
