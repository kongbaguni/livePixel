//
//  SignInView.swift
//  LivePixel
//
//  Created by 서창열 on 2023/08/21.
//

import SwiftUI
import AlamofireImage

struct SignInView: View {
    var id:String? {
#if targetEnvironment(simulator)
        return "test"
#else
        return AuthManager.shared.userId
#endif
    }
    
    @State var isSignIn:Bool = false
    
    @State var displayName:Text = Text("anomymouse signin")
    @State var profileImageURL:URL? = nil
    @State var isAnomymouse:Bool = false
    @State var alertMsg:Text = Text("") {
        willSet {
            isAlert = true
        }
    }
    
    @State var isAlert:Bool = false
    @State var alertAction:(()->Void)? = nil
    @State var isLoading:Bool = false
    var profile:ProfileModel? {
        return ProfileModel.current
    }
    private func refreshSigninName() {
#if targetEnvironment(simulator)
#else
        isSignIn = AuthManager.shared.auth.currentUser != nil
        isAnomymouse = AuthManager.shared.auth.currentUser?.isAnonymous ?? false
        
        print("uid : \(AuthManager.shared.auth.currentUser?.uid ?? "none")")
        if isAnomymouse {
            displayName = Text("anomymouse")
        }
        if let email = AuthManager.shared.auth.currentUser?.email {
            displayName = Text(email)
        }
        profileImageURL = AuthManager.shared.auth.currentUser?.photoURL
        
        #endif
    }
    
    private var deleteAccountButton : some View {
        RoundedButton(title: Text("delete account"), isLoading:$isLoading, style: .deleteStyle) {
            if AuthManager.shared.auth.currentUser?.isAnonymous == true {
                alertMsg = Text("delete anonymous account alert msg")
            } else {
                alertMsg = Text("delete account alert msg")
            }
            alertAction = {
                AuthManager.shared.leave { error in
                    refreshSigninName()
                }
            }
        }
    }
    
    private var appleSignIn : some View {
        AuthorizationButton(provider: .apple, sizeType: .large, authType: .signin) {
            refreshSigninName()
            AuthManager.shared.startSignInWithAppleFlow { isSucess, error in
                if let err = error {
                    alertMsg = Text(err.localizedDescription)
                }
                else {
                    refreshSigninName()
                }
            }
        }
    }
    
    private var appleUpgrade : some View {
        AuthorizationButton(provider: .apple, sizeType: .small, authType: .signin) {
            refreshSigninName()
            AuthManager.shared.upgradeAnonymousWithAppleId { isSucess, error in
                if let err = error {
                    alertMsg = Text(err.localizedDescription)
                }
                else {
                    refreshSigninName()
                }
            }
        }

    }
    
    private var googleSignIn : some View {
        AuthorizationButton(provider: .google, sizeType: .large, authType: .signin) {
            AuthManager.shared.startSignInWithGoogleId { loginSucess, error in
                if let err = error {
                    alertMsg = Text(err.localizedDescription)
                }
                else {
                    refreshSigninName()
                }
            }
        }
    }
    
    private var googleUpgrade : some View {
        AuthorizationButton(provider: .google, sizeType: .small, authType: .signin) {
            AuthManager.shared.upgradeAnonymousWithGoogleId { isSucess, error in
                if let err = error {
                    alertMsg = Text(err.localizedDescription)
                }
                else {
                    refreshSigninName()
                }
            }
        }
    }
    private var anonymousSignin : some View {
        AuthorizationButton(provider: .anonymous, sizeType: .large, authType: .signin) {
            AuthManager.shared.startSignInAnonymously { loginSucess, error in
                if let err = error {
                    alertMsg = Text(err.localizedDescription)
                }
                else {
                    refreshSigninName()
                }
            }
        }
    }
    var body: some View {
        ScrollView {
            if isSignIn {
                if let id = AuthManager.shared.userId {
                    ProfileView(id: id, editable: true)
                }
                
                HStack {
                    if isAnomymouse {
                        deleteAccountButton
                    }
                    else {
                        RoundedButton(title: Text("sign out"), isLoading: $isLoading) {
                            AuthManager.shared.signout()
                        }
                    }
                    
                    if isAnomymouse {
                        appleUpgrade
                        googleUpgrade
                    }
                    else {
                        deleteAccountButton
                    }
                }
            } else {
//                Text("signin")
                VStack {
                    appleSignIn
                    googleSignIn
                    anonymousSignin
                }
            }
        }
        .navigationTitle(isSignIn ? Text("profile") : Text("signin"))
        .padding(10)
//        .overlay {
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(lineWidth:2)
//        }
//        .padding(10)
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
            if let action = alertAction {
                return .init(
                    title: Text("alert"),
                    message: alertMsg,
                    primaryButton: .default(Text("confirm"), action: action), secondaryButton: .cancel())
            } else {
                return .init(title: Text("alert"), message: alertMsg)
            }
        }
        
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
        SignInView(
            isSignIn: true,
            displayName: Text("kongbaguni@gmail.com"),
            profileImageURL: URL(string: "https://img.freepik.com/premium-photo/cute-cat-cartoon-vector-icon-illustration_780593-3020.jpg"))
    }
}
