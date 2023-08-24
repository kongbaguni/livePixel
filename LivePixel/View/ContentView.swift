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
                                if let id = AuthManager.shared.userId {
                                    FSImageView(id: id,
                                                type: .profileImage, placeHolder: Image(systemName: "person.fill"))
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
