//
//  BlendmodeSelectView.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/09/01.
//

import SwiftUI
extension GraphicsContext.BlendMode {
    var stringValue:String {
        switch self {
        case .clear : return "clear"
        case .color : return "color"
        case .colorBurn : return "colorBurn"
        case .colorDodge : return "colorDodge"
        case .copy : return "copy"
        case .darken : return "darken"
        case .destinationAtop : return "destinationAtop"
        case .destinationIn : return "destinationIn"
        case .destinationOut : return "destinationOut"
        case .destinationOver : return "destinationOver"
        case .difference : return "difference"
        case .exclusion : return "exclusion"
        case .hardLight : return "hardLight"
        case .hue : return "hue"
        case .lighten : return "lighten"
        case .luminosity : return "luminosity"
        case .multiply : return "multiply"
        case .normal : return "normal"
        case .overlay : return "overlay"
        case .plusDarker : return "plusDarker"
        case .plusLighter : return "plusLighter"
        case .saturation : return "saturation"
        case .screen : return "screen"
        case .softLight : return "softLight"
        case .sourceAtop : return "sourceAtop"
        case .sourceIn : return "sourceIn"
        case .sourceOut : return "sourceOut"
        case .xor : return "xor"
        default: return ""
        }
    }
}

fileprivate let blendModes:[GraphicsContext.BlendMode] = [
    .clear,
    .color,
    .colorBurn,
    .colorDodge,
    .copy,
    .darken,
    .destinationAtop,
    .destinationIn,
    .destinationOut,
    .destinationOver,
    .difference,
    .exclusion,
    .hardLight,
    .hue,
    .lighten,
    .luminosity,
    .multiply,
    .normal,
    .overlay,
    .plusDarker,
    .plusLighter,
    .saturation,
    .screen,
    .softLight,
    .sourceAtop,
    .sourceIn,
    .sourceOut,
    .xor
]

struct BlendmodeSelectView: View {
           
    @Binding var blendMode:GraphicsContext.BlendMode
    @State var isSheet:Bool = false
    var body: some View {
        HStack {
            Text("blendMode")
            Button {
                isSheet = true
            } label: {
                RoundedLabel(title: Text(blendMode.stringValue), style: .defaultStyle)
            }
        }.actionSheet(isPresented: $isSheet) {
            var buttons:[ActionSheet.Button] = []
            for mode in blendModes {
                buttons.append(.default(Text(mode.stringValue), action:{
                    blendMode = mode
                }))
            }
            buttons.append(.cancel())
            return .init(title: Text("blendMode select"), buttons: buttons)
        }.padding(5)
    }
}

struct BlendmodeSelectView_Previews: PreviewProvider {
    static var previews: some View {
        BlendmodeSelectView(blendMode: .constant(.clear))
    }
}
