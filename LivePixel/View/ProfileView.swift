//
//  ProfileView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/23.
//

import SwiftUI

struct ProfileView: View {
    @State var profile:ProfileModel?
    
    func sync() {
        profile?.getInfo(complete: { model, error in
            self.profile = model
        })
    }
    
    var body: some View {
        VStack(alignment:.leading) {
            ZStack(alignment:.topTrailing) {
                NetImageView(
                    url: profile?.profileURL,
                    placeholder: Image(systemName: "person.fill"))
                if profile?.isMe == true {
                    NavigationLink {
                        ProfileEditView(profile: profile)
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
            Text(profile?.nickname ?? profile?.id ?? "없다")
                .font(.headline)
                .foregroundColor(.primary)
            if let intro = profile?.introduce {
                Text(intro)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

        }
//        .frame(width: 100)
        .onAppear {
#if !targetEnvironment(simulator)
            profile?.getInfo(complete: { model, error in
                if let model = model {
                    profile = model
                    print(model.profileURL ?? "프로파일 이미지 없다")
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
        ProfileView(profile: .init(id: "test"))
        ProfileView(profile: .init(
            id:"test@gmail.com",
            nickname: "고영희",
            introduce: "안녕하세요 나는 고영희입니다.\n안녕\n1\n2\n3?",
            profileURL: "https://img.freepik.com/premium-photo/a-drawing-of-a-cat-with-a-pink-background-and-the-word-cat-on-it_860805-3820.jpg"
        ))
    }
}