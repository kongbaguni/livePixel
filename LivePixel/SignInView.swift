//
//  SignInView.swift
//  LivePixel
//
//  Created by 서창열 on 2023/08/21.
//

import SwiftUI

struct SignInView: View {
    @State var displayName:String? = nil
    
    private func refreshSigninName() {
        displayName = AuthManager.shared.auth.currentUser?.email ??
        AuthManager.shared.userId
        print("-_--------")
        print(AuthManager.shared.auth.currentUser?.email)
        
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
                        refreshSigninName()
                    }
                } label: {
                    Text("signin with Apple")
                }
                
                Button {
                    AuthManager.shared.startSignInWithGoogleId { loginSucess, error in
                        print(loginSucess)
                        refreshSigninName()
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
        .onAppear {
            refreshSigninName()
        }
        
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
