//
//  FSImageView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/24.
//

import SwiftUI
/** FIrebase Storage 업로드된 이미지 뷰*/
struct FSImageView: View {
    let id:String
    let type:FirebaseStorageHelper.DataPath
    let placeHolder:Image
    @State var imgurl:String? = nil
    @State var error:Error? = nil
    var body: some View {
        ZStack {
            if let url = imgurl {
                NetImageView(url: url, placeholder: placeHolder, error: $error)
            } else {
                placeHolder.resizable().scaledToFit()
            }
//            if let err = error {
//                Button{
//                    refresh()
//                } label: {
//                    VStack {
//                        Image(systemName: "arrow.clockwise.circle.fill")
//                    }
//                }
//            }
        }
        .onAppear {
            refresh()
        }
    }
    
    func refresh() {
#if !targetEnvironment(simulator)
        if id.isEmpty == false {
            
            FirebaseStorageHelper.shared.getDownloadURL(
                uploadPath: type,
                id: id) { url, error in
                    self.error = error
                    guard let url = url else {
                        return
                    }
                    if self.imgurl == nil {
                        self.imgurl = url.absoluteString
                    } else {
                        self.imgurl = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) {
                            self.imgurl = url.absoluteString
                        }
                    }
            }
        }
#endif
    }
}

struct FSImageView_Previews: PreviewProvider {
    static var previews: some View {
        FSImageView(id: "", type: .profileImage, placeHolder: Image(systemName: "person.fill"))
    }
}