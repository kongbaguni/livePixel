//
//  ContentView.swift
//  LivePixel
//
//  Created by 서창열 on 2023/08/21.
//

import SwiftUI
import FirebaseCore
import RealmSwift
struct ContentView: View {
    init() {
        FirebaseApp.configure()
    }
    
    @State var isSignin = false
    
    var body: some View {
        NavigationView {
            NavigationStack {
                HomeView()
                    .toolbar {
                        NavigationLink {
                            SignInView(isSignIn: isSignin)
                        } label: {
                            Group {
                                ProfileImageViewForNavigation()
                            }.frame(width: 70)
                        }
                    }

            }

        }
        .navigationViewStyle(.stack)
        .onAppear {
            isSignin = AuthManager.shared.isSignined
        }
        .onReceive(NotificationCenter.default.publisher(for: .signoutDidSucessed)) { noti in
            isSignin = false
        }
        .onReceive(NotificationCenter.default.publisher(for: .authDidSucessed)) { noti in
            isSignin = true
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
