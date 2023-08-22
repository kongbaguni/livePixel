//
//  NetImageView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/22.
//

import SwiftUI
import Alamofire
import AlamofireImage

struct NetImageView: View {
    let url:String?
    @State var errorMsg:String? = nil
    @State var placeholder:SwiftUI.Image = .init(systemName: "photo.on.rectangle.angled")
    var body: some View {
        ZStack {
            if let msg = errorMsg {
                Text(msg)
            }
            placeholder
                .resizable()
                .scaledToFit()
                .blur(radius: errorMsg != nil ? 10 : 0)
                .opacity(errorMsg != nil ? 0.3 : 1.0)
        }
        .onAppear {
            guard let url = url else {
                return
            }
            AF.request(url).responseImage { response in
                let result = response.result
                switch result {
                case .success(let image) :
                    placeholder = .init(uiImage: image)
                case .failure(let error) :
                    errorMsg = error.localizedDescription
                }
            }
        }
    }
}

struct NetImageView_Previews: PreviewProvider {
    static var previews: some View {
        NetImageView(
            url:"https://img.freepik.com/premium-photo/cute-cat-cartoon-vector-icon-illustration_780593-3020.jpg")
    }
}
