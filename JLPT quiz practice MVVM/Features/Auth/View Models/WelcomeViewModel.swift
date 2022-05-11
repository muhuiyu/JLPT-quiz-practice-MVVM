//
//  WelcomeViewModel.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/10/22.
//

import RxRelay

class WelcomeViewModel {
    var state: BehaviorRelay<State> = BehaviorRelay(value: .empty)
    enum State {
        case empty
        case requestLogin
    }
    var displayTitleString: String { return "JLPT MVVM" }
    var displayGoogleLoginButtonTextString: String { return "Continue with Google" }
}

