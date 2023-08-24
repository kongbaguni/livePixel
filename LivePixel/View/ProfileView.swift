//
//  ProfileView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/23.
//

import SwiftUI
import RealmSwift
import RxSwift
import RxRealm

struct ProfileView: View {
    let id:String

    var isMe:Bool {
#if !targetEnvironment(simulator)
        return AuthManager.shared.userId == id
#else
        return true
#endif
    }
    @State var nickname = ""
    @State var introduce = ""

    let disposebag = DisposeBag()
    init(id: String) {
        self.id = id
        loadData()
        Observable.collection(from: Realm.shared.objects(ProfileModel.self))
            .subscribe { [self] event in
                switch event {
                case .next(_):
                    loadData()
                    break
                default:
                    break
                }
            }.disposed(by: disposebag)
        
    }
    
    func loadData() {
        if let data = Realm.shared.object(ofType: ProfileModel.self, forPrimaryKey: id) {
            nickname = data.nickname
            introduce = data.introduce
        }
    }
    
    var profile:ProfileModel? {
        Realm.shared.object(ofType: ProfileModel.self, forPrimaryKey: id)
    }
        
    var body: some View {
        VStack(alignment:.leading) {
            ZStack(alignment:.topTrailing) {
                FSImageView(id: id, type: .profileImage, placeHolder: Image(systemName: "person.fill"))
                if isMe == true {
                    NavigationLink {
                        ProfileEditView()
                    } label: {
                        Image(systemName: "pencil")
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
    }

}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(id:"test")
    }
}
