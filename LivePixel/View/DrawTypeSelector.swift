//
//  DrawTypeSelector.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/09/01.
//

import SwiftUI

struct DrawTypeSelector: View {
    @Binding var type:DoteModel.DrawType
    
    func makeImage(type:DoteModel.DrawType) -> some View {
        switch type {
        case .circle:
            return Image(systemName: "circle")
        case .horizontalLine:
            return Image(systemName: "square.split.1x2")
        case .verticalLine:
            return Image(systemName: "square.split.2x1")
        case .square:
            return Image(systemName: "square")
        }
    }
    
    func makeBtn(type:DoteModel.DrawType)-> some View {
        Button {
            self.type = type
        } label: {
            makeImage(type: type)
                .foregroundColor(self.type == type ? .red : .primary)
        }
    }
    
    var body: some View {
        HStack {
            ForEach(DoteModel.DrawType.allCases, id:\.self) { type in
               makeBtn(type: type)
            }
        }
    }
}

struct DrawTypeSelector_Previews: PreviewProvider {
    static var previews: some View {
        DrawTypeSelector(type: .constant(.square))
    }
}
