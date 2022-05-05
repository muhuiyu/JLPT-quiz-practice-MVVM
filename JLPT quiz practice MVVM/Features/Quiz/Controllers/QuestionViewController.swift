//
//  QuestionViewController.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/5/22.
//

import UIKit
import AVFoundation

//protocol QuestionViewControllerDelegate: AnyObject {
//    func questionViewControllerDidRequestGoNextQuestion(_ controller: QuestionViewController, didUserAnswerCorrectly isUserCorrect: Bool, atQuiz quiz: QuizEntry)
//    func questionViewControllerDidRequestRevealOptionEntryDetails(_ controller: QuestionViewController, with option: OptionEntry, as type: QuizType)
//    func questionViewController(_ controller: QuestionViewController, didRequestBookmarkQuestion quiz: QuizEntry)
//    func questionViewController(_ controller: QuestionViewController, didUserAnswerCorrectly isUserCorrect: Bool, didRequestMasterQuestion quiz: QuizEntry)
//}

class QuestionViewController: ViewController {
    
    private let questionLabel = UILabel()
    private let tableView = UITableView()
    private let saveButton = TextButton(frame: .zero, buttonType: .text)
    private let masteredButton = TextButton(frame: .zero, buttonType: .text)
    private let nextButton = TextButton(frame: .zero, buttonType: .primary)
    
    private var answerSoundEffect: AVAudioPlayer?
    
    var viewModel = QuestionViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.dataSource = self
//        tableView.delegate = self
        tableView.register(OptionCell.self, forCellReuseIdentifier: OptionCell.reuseID)
        configureViews()
        configureGestures()
        configureConstraints()
    }
}
// MARK: - Actions
extension QuestionViewController {
    private func didRequestGoNextQuestion() {

    }
    private func didRequestRevealOptionEntryDetails(at optionIndex: Int) {

    }
    private func didRequestBookmarkQuestion() {

    }
    private func didRequestMasterQuestion() {
        
    }
}
// MARK: - View Config
extension QuestionViewController {
    private func configureViews() {
        questionLabel.font = UIFont.body
        questionLabel.textColor = UIColor.label
//        questionLabel.text = entry.question
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .left
        view.addSubview(questionLabel)
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        view.addSubview(tableView)
        
        nextButton.tapHandler = {[weak self] in
            self?.didRequestGoNextQuestion()
        }
        nextButton.isHidden = true
        nextButton.text = "Next"
        view.addSubview(nextButton)
        
        masteredButton.tapHandler = {[weak self] in
            self?.didRequestMasterQuestion()
        }
        masteredButton.isHidden = true
        masteredButton.text = "I mastered this question already"
        view.addSubview(masteredButton)
        
//        saveButton.tapHandler = {[weak self] in
//            self?.didRequestBookmarkQuestion()
//        }
//        saveButton.isHidden = true
//        saveButton.text = "Bookmark this question"
//        view.addSubview(saveButton)
    }
    private func setViewMoreButtonInCells(asHidden: Bool) {
//        for i in 0...entry.options.count {
//            guard let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? OptionCell else { continue }
//            cell.isButtonHidden = asHidden
//        }
    }

    private func configureGestures() {
        
    }
    private func configureConstraints() {
        questionLabel.snp.remakeConstraints { make in
            make.top.equalTo(view.layoutMarginsGuide).inset(Constants.spacing.enormous)
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
        }
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(questionLabel.snp.bottom).offset(Constants.spacing.enormous)
            make.leading.trailing.bottom.equalToSuperview()
        }
        nextButton.snp.remakeConstraints { make in
            make.leading.trailing.equalTo(masteredButton)
            make.bottom.equalTo(masteredButton.snp.top).offset(-Constants.spacing.small)
        }
        masteredButton.snp.remakeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.layoutMarginsGuide)
        }
    }
}
// MARK: - Data Source
//extension QuestionViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return entry.options.count
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: OptionCell.reuseID, for: indexPath) as? OptionCell else {
//            return UITableViewCell()
//        }
//        cell.title = "\(indexPath.row + 1) - " + entry.options[indexPath.row].value
//        cell.buttonTapHandler = {[weak self] in
//            self?.didRequestRevealOptionEntryDetails(at: indexPath.row)
//        }
//        cell.selectionStyle = .none
//        return cell
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        defer {
//            tableView.deselectRow(at: indexPath, animated: true)
//        }
//        switch mode {
//        case .question:
//            if entry.options[indexPath.row].isAnswer {
//                guard let cell = tableView.cellForRow(at: indexPath) as? OptionCell else { return }
//                cell.status = .correct
//                self.isUserAnsweredCorrectly = true
//
//                let path = Bundle.main.path(forResource: "correct.m4a", ofType: nil)!
//                let url = URL(fileURLWithPath: path)
//                do {
//                    answerSoundEffect = try AVAudioPlayer(contentsOf: url)
//                    answerSoundEffect?.play()
//                } catch {
//                    print(error)
//                }
//            }
//            else {
//                guard
//                    let selectedCell = tableView.cellForRow(at: indexPath) as? OptionCell,
//                    let answerCell = tableView.cellForRow(at: IndexPath(row: entry.getAnswerIndex(), section: 0)) as? OptionCell
//                else { return }
//
//                selectedCell.status = .wrong
//                answerCell.status = .correct
//                self.isUserAnsweredCorrectly = false
//
//                let path = Bundle.main.path(forResource: "wrong.m4a", ofType: nil)!
//                let url = URL(fileURLWithPath: path)
//                do {
//                    answerSoundEffect = try AVAudioPlayer(contentsOf: url)
//                    answerSoundEffect?.play()
//                } catch {
//                    print(error)
//                }
//            }
//            self.mode = .review
//        default: return
//        }
//    }
//}

