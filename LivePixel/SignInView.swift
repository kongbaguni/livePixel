//
//  SignInView.swift
//  LivePixel
//
//  Created by 서창열 on 2023/08/21.
//

import SwiftUI

struct SignInView: View {
    var previewMode = false
    @State var displayName:String? = nil
    
    private func refreshSigninName() {
        if previewMode {
            return
        }
        displayName = AuthManager.shared.auth.currentUser?.email
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
                AuthorizationButton(provider: .apple, sizeType: .large, authType: .signin) {
                    refreshSigninName()
                    AuthManager.shared.startSignInWithAppleFlow { loginSucess, error in
                        refreshSigninName()
                    }

                }
                AuthorizationButton(provider: .google, sizeType: .large, authType: .signin) {
                    AuthManager.shared.startSignInWithGoogleId { loginSucess, error in
                        refreshSigninName()
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
        
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(previewMode:true)
    }
}
