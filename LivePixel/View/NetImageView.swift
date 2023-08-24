//
//  NetImageView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/22.
//

import SwiftUI
import Alamofire
import AlamofireImage
import Kingfisher
struct NetImageView: View {
    let url:String?
    @State var placeholder:SwiftUI.Image = .init(systemName: "photo.on.rectangle.angled")
    @Binding var error:Error?
    var body: some View {
        ZStack {
            if let url = url {
                KFImage(URL(string: url))
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
            } else {
                placeholder
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
            }
        }
    }
}

struct NetImageView_Previews: PreviewProvider {
    static var previews: some View {
        NetImageView(
            url:"https://img.freepik.com/premium-photo/cute-cat-cartoon-vector-icon-illustration_780593-3020.jpg", error:.constant(nil))
        NetImageView(
            url:nil,error: .constant(nil))
    }
}
