//
//  AuthenticationViewModel.swift
//  JLPT quiz practice MVVM
//
//  Created by Mu Yu on 5/10/22.
//

import Firebase
import GoogleSignIn
import RxRelay

class AuthenticationViewModel {
    var state: BehaviorRelay<SignInState> = BehaviorRelay(value: .signedOut)
    
    enum SignInState {
        case signedIn
        case signedOut
    }
    
    init() {
        self.state.accept(.signedOut)
    }
}

extension AuthenticationViewModel {
    var displayTitleString: String { return "JLPT MVVM" }
    var displayGoogleLoginButtonTextString: String { return "Continue with Google" }
}

extension AuthenticationViewModel {
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }

        guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)

        Auth.auth().signIn(with: credential) { [unowned self] (_, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.state.accept(.signedIn)
            }
        }
    }
    func signIn() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                authenticateUser(for: user, with: error)
            }
        } else {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            let configuration = GIDConfiguration(clientID: clientID)
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
            
            GIDSignIn.sharedInstance.signIn(with: configuration, presenting: rootViewController) { [unowned self] user, error in
                authenticateUser(for: user, with: error)
            }
        }
    }
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        do {
            try Auth.auth().signOut()
            state.accept(.signedOut)
        } catch {
            print(error.localizedDescription)
        }
    }
}
