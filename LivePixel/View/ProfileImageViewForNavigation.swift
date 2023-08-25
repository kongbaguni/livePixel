//
//  ProfileButtonViewForNavigation.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/24.
//

import SwiftUI

struct ProfileImageViewForNavigation: View {
#if !targetEnvironment(simulator)
    @State var id:String? = AuthManager.shared.userId
#else
    @State var id:String? = nil
#endif
    var body: some View {
        Group {
            if let id = id {
                FSImageView(id: id,
                            type: .profileImage, placeHolder: Image(systemName: "person.fill"))
            } else {
                Image(systemName: "person.fill")
            }
        }.onReceive(NotificationCenter.default.publisher(for: .signoutDidSucessed)) { noti in
            id = nil
        }.onReceive(NotificationCenter.default.publisher(for: .authDidSucessed)) { noti in
            id = AuthManager.shared.userId
        }
        
    }
}

struct ProfileImageViewForNavigation_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImageViewForNavigation()
    }
}
