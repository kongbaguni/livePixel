//
//  ColorMixerView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/29.
//

import SwiftUI

struct ColorMixerView: View {
    @Binding var color:Color
    @State var red:Double = 0 {
        didSet {
            setColor()
        }
    }
    @State var green:Double = 0
    @State var blue:Double = 0
    @State var alpha:Double = 0
    
    
    
    var body: some View {
        HStack {
            ColorPicker(selection: $color) {
                color.frame(width: 100,height: 100)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.primary, lineWidth: 2)
                    }
                    .cornerRadius(10)

            }
            VStack {
                HStack {
                    ColorView(backgroundColor: .black,
                              color: .init(red: 1, green: 0, blue: 0),
                              opacity: red).frame(width: 20, height: 20)
                    Slider(value: $red)
                        .accentColor(.init(red: 1, green: 0, blue: 0))
                }
                HStack {
                    ColorView(backgroundColor: .black,
                              color: .init(red: 0, green: 1, blue: 0),
                              opacity: green).frame(width: 20, height: 20)
                    Slider(value: $green)
                        .accentColor(.init(red: 0, green: 1, blue: 0))
                }
                HStack {
                    ColorView(backgroundColor: .black,
                              color: .init(red: 0, green: 0, blue: 1),
                              opacity: blue).frame(width: 20, height: 20)
                    Slider(value: $blue)
                        .accentColor(.init(red: 0, green: 0, blue: 1))
                }
                Slider(value: $alpha)
                    .accentColor(.init(white:1))
            }
        }
        .padding(20)
        .onAppear {
            load()
        }
        .onChange(of: red) { newValue in
            setColor()
        }
        .onChange(of: green) { newValue in
            setColor()
        }
        .onChange(of: blue) { newValue in
            setColor()
        }
        .onChange(of: alpha) { newValue in
            setColor()
        }
    }
    func load() {
        let ci = color.ciColor
        red = ci.red
        green = ci.green
        blue = ci.blue
        alpha = ci.alpha
    }
    func setColor() {
        color = .init(.sRGBLinear,red: red, green: green, blue: blue, opacity: alpha)
    }
}

struct ColorMixerView_Previews: PreviewProvider {
    static var previews: some View {
        ColorMixerView(color:.constant(.red))
    }
}
