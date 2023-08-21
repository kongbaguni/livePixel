//
//  SignInView.swift
//  LivePixel
//
//  Created by 서창열 on 2023/08/21.
//

import SwiftUI

struct SignInView: View {
    @State var displayName:String? = nil
    init() {
        refreshSigninName()
    }
    
    private func refreshSigninName() {
        AuthManager.shared.isSignined
        
        displayName = AuthManager.shared.auth.currentUser?.displayName
    }
    
    var body: some View {
        VStack {
            if let name = displayName {
                Text(name)
                Button {
                    AuthManager.shared.signout()
                } label: {
                    Text("sign out")
                }
            } else {
                Button {
                    AuthManager.shared.startSignInWithAppleFlow { loginSucess, error in
                        print(loginSucess)
                    }
                } label: {
                    Text("signin with Apple")
                }
                
                Button {
                    AuthManager.shared.startSignInWithGoogleId { loginSucess, error in
                        print(loginSucess)
                        
                    }
                } label: {
                    Text("signin with Google")
                }

            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .authDidSucessed)) { noti in
            refreshSigninName()
        }
        .onReceive(NotificationCenter.default.publisher(for: .signoutDidSucessed)) { noti in
            refreshSigninName()
        }
        
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
