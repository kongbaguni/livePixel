//
//  ProfileEditView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/23.
//

import SwiftUI

struct ProfileEditView: View {
    @State var profile:ProfileModel?

    @State var nickname:String = ""
    @State var introduce:String = ""
    func makeButton(title:Text,placeHolder:String,value:Binding<String>,prompt:Text?)-> some View {
        HStack {
            title
            TextField(placeHolder, text: value, prompt: prompt)
                .textFieldStyle(.roundedBorder)
        }
    }
    var body: some View {
        List {
            makeButton(title: Text("nickname"), placeHolder: profile?.id ?? "nickname" , value: $nickname, prompt: nil)
            
            makeButton(title: Text("introduce"), placeHolder: "input introduce", value: $introduce, prompt: Text("input introduce"))
            
            RoundedButton(title: Text("save")) {
                save()
            }
        }
        .padding(20)
        .onAppear {
#if !targetEnvironment(simulator)
            load()
#endif
        }
        .navigationTitle(Text("edit profile"))
    }
    
    func load() {
        nickname = profile?.nickname ?? ""
        introduce = profile?.introduce ?? ""
    }
    func save() {
        profile?.nickname = nickname
        profile?.introduce = introduce
        profile?.update{ error in
            
        }
    }
}

struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView(profile: .init(id: "test"))
    }
}
