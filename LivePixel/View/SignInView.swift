//
//  SignInView.swift
//  LivePixel
//
//  Created by 서창열 on 2023/08/21.
//

import SwiftUI
import AlamofireImage

struct SignInView: View {
    @State var isSignIn:Bool = false
    @State var displayName:Text = Text("anomymouse signin")
    @State var profileImageURL:URL? = nil
    @State var isAnomymouse:Bool = false
    @State var alertMsg:String = "" {
        willSet {
            isAlert = true
        }
    }
    
    @State var isAlert:Bool = false
    private func refreshSigninName() {
        #if targetEnvironment(simulator)
        #else
        isSignIn = AuthManager.shared.auth.currentUser != nil
        isAnomymouse = AuthManager.shared.auth.currentUser?.isAnonymous ?? false
        
        if isAnomymouse {
            displayName = Text("anomymouse")
        }
        if let email = AuthManager.shared.auth.currentUser?.email {
            displayName = Text(email)
        }
        profileImageURL = AuthManager.shared.auth.currentUser?.photoURL
        
        #endif
    }
    
    var body: some View {
        VStack {
            if isSignIn {
                NetImageView(url: profileImageURL?.absoluteString, placeholder: Image(systemName: "person"))
                displayName
                HStack {
                    RoundedButton(title: Text("sign out")) {
                        if isAnomymouse {
                            AuthManager.shared.leave { error in
                                refreshSigninName()
                            }
                        } else {
                            AuthManager.shared.signout()
                        }
                    }
                    
                    if isAnomymouse {
                        VStack {
                            AuthorizationButton(provider: .apple, sizeType: .large, authType: .signin) {
                                refreshSigninName()
                                AuthManager.shared.upgradeAnonymousWithAppleId { isSucess, error in
                                    if let err = error {
                                        alertMsg = err.localizedDescription
                                    }
                                    else {
                                        refreshSigninName()
                                    }
                                }
                            }
                            AuthorizationButton(provider: .google, sizeType: .large, authType: .signin) {
                                AuthManager.shared.upgradeAnonymousWithGoogleId { isSucess, error in
                                    if let err = error {
                                        alertMsg = err.localizedDescription
                                    }
                                    else {
                                        refreshSigninName()
                                    }
                                }
                            }
                        }
                    }
                    else {
                        RoundedButton(title: Text("delete account"), style: .deleteStyle) {
                            AuthManager.shared.leave { error in
                                if let err = error {
                                    alertMsg = err.localizedDescription
                                }
                                else {
                                    refreshSigninName()
                                }
                            }
                        }
                    }
                }
            } else {
                AuthorizationButton(provider: .apple, sizeType: .large, authType: .signin) {
                    refreshSigninName()
                    AuthManager.shared.startSignInWithAppleFlow { loginSucess, error in
                        if let err = error {
                            alertMsg = err.localizedDescription
                        }
                        else {
                            refreshSigninName()
                        }
                    }

                }
                AuthorizationButton(provider: .google, sizeType: .large, authType: .signin) {
                    AuthManager.shared.startSignInWithGoogleId { loginSucess, error in
                        if let err = error {
                            alertMsg = err.localizedDescription
                        }
                        else {
                            refreshSigninName()
                        }
                    }
                    
                }
                RoundedButton(title: Text("anomymouse signin")) {
                    AuthManager.shared.startSignInAnonymously { loginSucess, error in
                        if let err = error {
                            alertMsg = err.localizedDescription
                        }
                        else {
                            refreshSigninName()
                        }
                    }
                }
            }
        }
        .padding(10)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth:2)
        }
        .padding(10)
        .onReceive(NotificationCenter.default.publisher(for: .authDidSucessed)) { noti in
            refreshSigninName()
        }
        .onReceive(NotificationCenter.default.publisher(for: .signoutDidSucessed)) { noti in
            refreshSigninName()
        }
        .onAppear {
            refreshSigninName()
        }
        .alert(isPresented: $isAlert) {
            .init(title: Text("alert"), message: Text(alertMsg))
        }
        
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
        SignInView(
            isSignIn: true,
            displayName: Text("kongbaguni@gmail.com"), profileImageURL: URL(string: "https://img.freepik.com/premium-photo/cute-cat-cartoon-vector-icon-illustration_780593-3020.jpg"))
    }
}
