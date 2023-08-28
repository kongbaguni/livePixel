//
//  Color+Extensions.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/28.
//

import Foundation
import SwiftUI

extension Color {
    var ciColor:CIColor {
        let cgColor = UIColor(self).cgColor
        return CIColor(cgColor: cgColor)
    }
}
