//
//  RoundedButton.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/22.
//

import SwiftUI

struct RoundedButton: View {
    struct ButtonStyle {
        let borderColor:Color
        let textColor:Color
        let font:Font
        let backgroundColor:Color
        let cornerRadius:CGFloat
        let borderWidth:CGFloat
        static let deleteStyle:ButtonStyle = .init(borderColor: .red, textColor: .red, font: .body, backgroundColor: .yellow, cornerRadius: 10, borderWidth: 5)
    }
    
    let title:Text
    var style:ButtonStyle? = nil
    let action:()->Void
    var body: some View {
        Button(action: action) {
            title
                .foregroundColor(style?.textColor ?? .accentColor)
                .font(style?.font ?? .body)
        }
        .padding(10)
        .background(style?.backgroundColor ?? .clear)
        .cornerRadius(style?.cornerRadius ?? 10)
        .overlay {
            RoundedRectangle(cornerRadius: style?.cornerRadius ?? 10)
                .stroke(style?.borderColor ?? .accentColor, lineWidth: style?.borderWidth ?? 5)
                
        }
        .padding(5)
    }
}

struct RoundedButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundedButton(title: Text("button")) {
            
        }
        RoundedButton(title: Text("buton"), style:.init(
            borderColor: .green,
            textColor: .red,
            font: .system(size: 30,weight: .heavy),
            backgroundColor: .yellow,
            cornerRadius: 20,
            borderWidth: 5
        )
        ) {
            
        }
    }
}
