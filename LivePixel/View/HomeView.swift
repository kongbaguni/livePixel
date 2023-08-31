//
//  HomeView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/25.
//

import SwiftUI

struct HomeView: View {
    @State var isSignin = AuthManager.shared.isSignined
    
    var body: some View {
        Group {
            if isSignin {
                VStack {
                    SubjectListView()
                }
            } else {
                VStack {
                    Text("Live Pixel")
                }
            }
        }
        .navigationTitle("Home")
        .onReceive(NotificationCenter.default.publisher(for: .authDidSucessed)) { noti in
            isSignin = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .signoutDidSucessed)) { noti in
            isSignin = false
        }
        

        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
