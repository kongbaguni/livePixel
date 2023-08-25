//
//  Canvas.swift
//  LivePixel
//
//  Created by 서창열 on 2023/08/21.
//

import Foundation
import SwiftUI
import RealmSwift

class CanvasModel : Object {
    @Persisted(primaryKey: true) var id:String = ""
    @Persisted var title:String = ""
    @Persisted var ownerId:String = ""
    @Persisted var updateDt:Double = Date().timeIntervalSince1970
    
    struct ThreadSafeModel : Hashable {
        static func == (left:ThreadSafeModel, right:ThreadSafeModel)-> Bool {
            return left.id == right.id
        }
        let id:String
        let title:String
        let onwerId:String
        let updateDt:Double
        
        var updateDate:Date {
            return Date(timeIntervalSince1970: updateDt)
        }
    }
}

extension CanvasModel {
    var threadSafeModel:ThreadSafeModel {
        return .init(id: id, title: title, onwerId: ownerId, updateDt: updateDt)
    }
}
