//
//  ProfileEditView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/23.
//

import SwiftUI
import PhotosUI
import AlamofireImage

struct ProfileEditView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var profile:ProfileModel?

    @State var nickname:String = ""
    @State var introduce:String = ""
    @State var isAlert:Bool = false
    @State var alertMsg:Text = Text("")
    @State var isSheetPhotoPicker = false
    @State var images:[UIImage] = []
    func makeInputField(title:Text,placeHolder:String,value:Binding<String>,prompt:Text?)-> some View {
        HStack {
            title
            TextField(placeHolder, text: value, prompt: prompt)
                .textFieldStyle(.roundedBorder)
        }
    }
    var body: some View {
        List {
            makeInputField(title: Text("nickname"), placeHolder: profile?.id ?? "nickname" , value: $nickname, prompt: nil)
            
            makeInputField(title: Text("introduce"), placeHolder: "input introduce", value: $introduce, prompt: Text("input introduce"))
            
            HStack {
                
                if let img = images.first {
                    Image(uiImage: img).resizable().scaledToFit()
                } else {
                    if let url = profile?.profileURL {
                        NetImageView(url: url, placeholder: Image(systemName: "person.fill"))
                    } else {
                        Text("profile image")
                    }
                }
                RoundedButton(title: Text("select image")) {
                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                        switch status {
                        case .authorized:
                            isSheetPhotoPicker = true
                        default:
                            break
                        }
                    }
                }
            }
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
        .alert(isPresented: $isAlert) {
            .init(title: Text("alert"), message: alertMsg)
        }
        .sheet(isPresented: $isSheetPhotoPicker) {
            PhotoPicker(images: $images)
        }
    }
    
    func load() {
        nickname = profile?.nickname ?? ""
        introduce = profile?.introduce ?? ""
    }
    func save(profileUrl:String? = nil) {
        guard let id = AuthManager.shared.userId else {
            return
        }
        
        
        
        if let data = images.first?.af.imageAspectScaled(toFit: .init(width: 200, height: 200)).jpegData(compressionQuality: 0.7) {
            
            FirebaseStorageHelper.shared.uploadData(data: data, contentType: .jpeg, uploadPath: "profileimages", id: id) { downloadURL, error in
                if let err = error {
                    alertMsg = Text(err.localizedDescription)
                    isAlert = true
                }
                else {
                    images.removeAll()
                    save(profileUrl: downloadURL?.absoluteString)
                }
            }
            return
        }
        profile?.nickname = nickname
        profile?.introduce = introduce
        profile?.profileURL = profileUrl
        profile?.update{ error in
            if let err = error {
                alertMsg = Text(err.localizedDescription)
                isAlert = true
            }
            else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView(profile: .init(id: "test"))
    }
}
