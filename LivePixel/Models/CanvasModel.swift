//
//  Canvas.swift
//  LivePixel
//
//  Created by 서창열 on 2023/08/21.
//

import Foundation
import SwiftUI
struct CanvasModel {
    let size:CGSize
    var data:Stack<DoteModel> = .init()    
}
