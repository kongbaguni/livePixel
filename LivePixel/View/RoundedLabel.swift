//
//  RoundedNavigationLink.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/31.
//

import SwiftUI

struct RoundedLabel: View {
    struct LabelStyle : Hashable {
        let font:Font
        let textColor:Color
        let backgroundColor:Color
        let borderColor:Color
        let borderWidth:CGFloat
        let cornerRadius:CGFloat
        let padding:CGFloat
        let margin:CGFloat
        static let defaultStyle:LabelStyle = .init(
            font: .body,
            textColor: .primary,
            backgroundColor: .clear,
            borderColor: .primary,
            borderWidth: 2,
            cornerRadius: 10,
            padding: 10,
            margin: 10)
        
    }
    
    let title:Text
    let style:LabelStyle
    var body: some View {
        title
            .foregroundColor(style.textColor)
            .padding(style.padding)
            .background(style.backgroundColor)
            .cornerRadius(style.cornerRadius)
            .overlay {
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
                
            }
            .padding(style.margin)
    }
}

struct RoundedLabel_Previews: PreviewProvider {
    static var previews: some View {
        RoundedLabel(title: Text("test"),
                     style: .defaultStyle)
    }
}
