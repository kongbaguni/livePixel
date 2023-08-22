//
//  ContentView.swift
//  LivePixel
//
//  Created by 서창열 on 2023/08/21.
//

import SwiftUI
import FirebaseCore

struct ContentView: View {
    init() {
        FirebaseApp.configure()
    }
    var body: some View {
        VStack {
            HStack {
                SignInView()
                    .frame(width:300, height: 300)
            }
        }
        .padding()
       
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
