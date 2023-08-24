//
//  ContentView.swift
//  LivePixel
//
//  Created by 서창열 on 2023/08/21.
//

import SwiftUI
import FirebaseCore

struct ContentView: View {
    @State var profileURL:String? = nil
    init() {
        #if !targetEnvironment(simulator)
        FirebaseApp.configure()
        #endif
    }
    var body: some View {
        NavigationView {
            NavigationStack {
                CanvasView()
                    .navigationTitle(Text("canvas"))
                    .toolbar {
                        NavigationLink {
#if !targetEnvironment(simulator)
                            SignInView(isSignIn: AuthManager.shared.isSignined)
                            #else
                            SignInView()
                            #endif
                            
                        } label: {
                            Group {
#if !targetEnvironment(simulator)
                                if let url = profileURL {
                                    NetImageView(url: url, placeholder: Image(systemName: "person.fill"), error: .constant(nil))
                                } else {
                                    Image(systemName: "person.fill")
                                }
#else
                                Image(systemName: "person.fill")
#endif
                            }.frame(width: 70)
                        }
                    }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
#if !targetEnvironment(simulator)
            profileURL = AuthManager.shared.auth.currentUser?.photoURL?.absoluteString
            print("profileURL : \(profileURL ?? "none")")

#endif
        }
        .onReceive(NotificationCenter.default.publisher(for: .authDidSucessed)) { noti in
            profileURL = AuthManager.shared.auth.currentUser?.photoURL?.absoluteString
            print("profileURL : \(profileURL ?? "none")")
        }
        .onReceive(NotificationCenter.default.publisher(for: .signoutDidSucessed)) { noti in
            profileURL = nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
