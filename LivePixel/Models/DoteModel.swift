//
//  DoteModel.swift
//  LivePixel
//
//  Created by 서창열 on 2023/08/21.
//

import Foundation
import SwiftUI
struct DoteModel {
    let position:CGPoint
    let color:Color
    let timeStemp:Date
    
    init(position: CGPoint, color: Color) {
        self.position = position
        self.color = color
        self.timeStemp = Date()
    }
}
