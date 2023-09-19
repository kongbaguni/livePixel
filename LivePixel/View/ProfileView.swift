//
//  ProfileView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/23.
//

import SwiftUI
import RealmSwift
import RealmSwift

struct ProfileView: View {
    let id:String
    let editable:Bool

    var isMe:Bool {
        return AuthManager.shared.userId == id
    }
    @State var nickname = ""
    @State var introduce = ""

    init(id: String, editable:Bool) {
        self.id = id
        self.editable = editable
        loadData()        
    }
    
    func loadData() {
        if let data = Realm.shared.object(ofType: ProfileModel.self, forPrimaryKey: id) {
            nickname = data.nickname
            introduce = data.introduce
        } else {
            FirebaseFirestoreHelper.shared.getProfile(id: id) { error in
//                loadData()
            }
        }
    }
    
    var profile:ProfileModel? {
        Realm.shared.object(ofType: ProfileModel.self, forPrimaryKey: id)
    }
        
    var body: some View {
        VStack(alignment:.leading) {
            ZStack(alignment:.topTrailing) {
                FSImageView(id: id, type: .profileImage, placeHolder: Image(systemName: "person.fill"))
                    .frame(maxWidth: 300)
                if isMe && editable{
                    NavigationLink {
                        ProfileEditView()
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .resizable().frame(width: 50, height: 50)
                            .padding(5)
                            .foregroundColor(Color("normalText"))
                            .background(Color("dim"))
                            .cornerRadius(30)
                            .padding(5)
                    }
                }
            }
            Text(nickname)
                .font(.headline)
                .foregroundColor(.primary)
            if introduce.isEmpty == false  {
                Text(introduce)
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
        .onAppear {
            loadData()
        }
        .shadow(radius: 10)
        .padding(10)
        .onReceive(NotificationCenter.default.publisher(for: .authDidSucessed)) { noti in
            loadData()
        }

    }

}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(id:"test", editable: true)
    }
}
