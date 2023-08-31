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
        }
        .onAppear {
            refresh()
        }
    }
    
    func refresh() {
        if id.isEmpty == false {
            if let cache = FirestorageDownloadUrlCacheModel.get(id: id) {
                self.imgurl = cache.url
                return
            }
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
    }
}

struct FSImageView_Previews: PreviewProvider {
    static var previews: some View {
        FSImageView(id: "", type: .profileImage, placeHolder: Image(systemName: "person.fill"))
    }
}
