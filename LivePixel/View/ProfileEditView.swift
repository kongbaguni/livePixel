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

    var profile:ProfileModel? {
        return ProfileModel.current
    }

    @State var nickname:String = ""
    @State var introduce:String = ""
    @State var isAlert:Bool = false
    @State var alertMsg:Text = Text("")
    @State var isSheetPhotoPicker = false
    @State var images:[UIImage] = []
    @State var alertConfirmAction:(()->Void)? = nil
    @State var isLoading:Bool = false
    
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
                    let newimg = img.af.imageAspectScaled(toFill: .init(width: 200, height: 200))
                    Image(uiImage: newimg).resizable().scaledToFit()
                } else {
                    if let id = profile?.id {
                        FSImageView(id: id, type: .profileImage, placeHolder: Image(systemName: "person.fill"))
                    }
                }
                RoundedButton(title: Text("select image"), isLoading: $isLoading) {
                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                        switch status {
                        case .authorized:
                            isSheetPhotoPicker = true
                        default:
                            alertMsg = Text("photo permission alert")
                            alertConfirmAction = {
                                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                            }
                            isAlert = true
                            break
                        }
                    }
                }
            }
            RoundedButton(title: Text("save"),isLoading: $isLoading) {
                save()
            }
        }
        .padding(20)
        .onAppear {
            load()
        }
        .navigationTitle(Text("edit profile"))
        .alert(isPresented: $isAlert) {
            if let action = alertConfirmAction {
                return .init(title: Text("alert"), message: alertMsg,
                             primaryButton: .default(Text("confirm"), action: action),
                             secondaryButton: .cancel())
            } else {
                return .init(title: Text("alert"), message: alertMsg)
            }
        }
        .sheet(isPresented: $isSheetPhotoPicker) {
            PhotoPicker(images: $images)
        }
    }
    
    func load() {
        nickname = profile?.nickname ?? ""
        introduce = profile?.introduce ?? ""
    }
    func save() {
        guard let id = AuthManager.shared.userId else {
            return
        }
        
        if let data = images.first?.af.imageAspectScaled(toFill: .init(width: 200, height: 200)).jpegData(compressionQuality: 0.7) {
            FirebaseStorageHelper.shared.uploadData(data: data, contentType: .jpeg, uploadPath: .profileImage, id: id) { downloadURL, error in
                if let url = downloadURL {
                    _ = FirestorageDownloadUrlCacheModel.reg(id: id, url: url.absoluteString)
                }
                if let err = error {
                    alertMsg = Text(err.localizedDescription)
                    alertConfirmAction = nil
                    isAlert = true
                }
                else {
                    images.removeAll()
                    save()
                }
            }
            return
        }
        let data = [
            "id" : id,
            "nickname" : nickname,
            "introduce" : introduce,
        ]
        
        if profile?.updateData(data: data) == nil {
            isLoading = true
            FirebaseFirestoreHelper.shared.profileUpload(id: id) { error in
                isLoading = false 
                if let err = error {
                    alertMsg = Text(err.localizedDescription)
                    alertConfirmAction = nil
                    isAlert = true
                }
                else {
                    presentationMode.wrappedValue.dismiss()
                }

            }
        }
    }
}

struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView()
    }
}
