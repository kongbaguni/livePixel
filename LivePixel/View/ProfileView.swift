//
//  ProfileView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/23.
//

import SwiftUI

struct ProfileView: View {
    @State var profile:ProfileModel?
    
    @State var nickname:String = "없다"
    var body: some View {
        VStack(alignment:.leading) {
            NetImageView(
                url: profile?.profileURL,
                placeholder: Image(systemName: "person.fill"))
            Text(profile?.nickname ?? profile?.id ?? nickname)
                .font(.headline)
                .foregroundColor(.primary)
            if let intro = profile?.introduce {
                Text(intro)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
            }
            if profile?.isMe == true {
                NavigationLink {
                    ProfileEditView(profile: profile)                    
                } label: {
                    Image(systemName: "pencil")
                }
            }

        }
        .frame(width: 100)
        .onAppear {
#if !targetEnvironment(simulator)
            profile?.getInfo(complete: { model, error in
                if let model = model {
                    profile = model
                }
            })
#endif
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
        ProfileView(profile: .init(
            id:"test@gmail.com",
            nickname: nil,//"고영희",
            introduce: nil,// "안녕하세요 나는 고영희입니다.\n안녕\n1\n2\n3?",
            profileURL: "https://img.freepik.com/premium-photo/a-drawing-of-a-cat-with-a-pink-background-and-the-word-cat-on-it_860805-3820.jpg"
        ))
    }
}
