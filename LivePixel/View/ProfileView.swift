//
//  ProfileView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/23.
//

import SwiftUI
import RealmSwift
struct ProfileView: View {
    let id:String
    var profile:ProfileModel? {
        return try? Realm().object(ofType: ProfileModel.self, forPrimaryKey: id)
    }
        
    var body: some View {
        VStack(alignment:.leading) {
            ZStack(alignment:.topTrailing) {
                if let url = profile?.profileURL {
                    NetImageView(
                        url: url,
                        placeholder: Image(systemName: "person.fill"))
                }
                if profile?.isMe == true {
                    NavigationLink {
                        ProfileEditView()
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
            Text(profile?.nickname ?? profile?.id ?? "")
                .font(.headline)
                .foregroundColor(.primary)
            if let intro = profile?.introduce {
                Text(intro)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

        }
        .padding(10)
        .background(Color("dim"))
        .cornerRadius(20)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 2)
        }
        .shadow(radius: 10)
        .padding(10)
    }

}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(id:"test")
    }
}
