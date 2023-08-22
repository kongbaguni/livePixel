//
//  SigninButton.swift
//  PixelArtMaker (iOS)
//
//  Created by 서창열 on 2022/04/07.
//

import SwiftUI
import GoogleSignIn
import AuthenticationServices

struct AuthorizationButton : View {
    
    enum ProviderType {
        case apple
        case google
    }

    enum ButtonSize {
        case small
        case large
    }
    
    enum AuthType {
        case signin
        case signup
    }
    
    let provider:ProviderType
    let sizeType:ButtonSize
    let authType:AuthType
    let action:()->Void

    private var headImage : some View {
        switch provider {
        case .apple:
            return Image("signin_logo_apple").resizable().frame(width: 30, height: 30, alignment: .center)
        case .google:
            return Image("signin_logo_google").resizable().frame(width: 30, height: 30, alignment: .center)
        }
    }

    private var text:Text {
        switch provider {
        case .apple:
            switch authType {
            case .signin:
                return Text("Sign in with Apple")
            case .signup:
                return Text("Sign up with Apple")
            }
        case .google:
            switch authType {
            case .signin:
                return Text("Sign in with Google")
            case .signup:
                return Text("Sign up with Google")
            }
        }
    }
    
    private var backgroundColor:Color {
        switch provider {
        case .apple:
            return Color("signinBtnBackgroundApple")
        case .google:
            return Color("signinBtnBackgroundGoogle")
        }
    }
    
    
    private var btnLabel : some View {
        VStack {
            switch sizeType {
            case .small:
                headImage
                    .padding(5)

            case .large:
                HStack {
                    Spacer()
                    headImage
                        .padding(5)
                    text
                        .foregroundColor(.primary)
                        .font(.headline)
                    Spacer()
                }
            }
        }
    }
    
    var body : some View {
        Button {
            action()
        } label : {
            btnLabel
        }
        .background(backgroundColor)
        .cornerRadius(30)
        .overlay(
            RoundedRectangle(cornerRadius: 30).stroke(Color.primary, lineWidth:1)
        )
    }
}
struct AuthorizationButton_Preview: PreviewProvider {
    static var previews: some View {
        AuthorizationButton(provider: .apple, sizeType: .large, authType: .signin) {
            
        }
        AuthorizationButton(provider: .google, sizeType: .large, authType: .signin) {
            
        }
        

    }
}
