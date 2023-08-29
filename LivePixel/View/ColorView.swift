//
//  ColorView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/29.
//

import SwiftUI

struct ColorView: View {
    let backgroundColor : Color
    let color : Color
    let opacity : Double
    var body: some View {
        ZStack {
            backgroundColor
            color.opacity(opacity)
        }
    }
}

struct ColorView_Previews: PreviewProvider {
    static var previews: some View {
        ColorView(backgroundColor: .black, color: .red, opacity: 0.9)
    }
}
