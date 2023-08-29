//
//  DoteModel.swift
//  LivePixel
//
//  Created by 서창열 on 2023/08/21.
//

import Foundation
import SwiftUI
import RealmSwift

class DoteModel:Object {
    @Persisted(primaryKey: true) var id:String = ""
    @Persisted var canvasId:String = ""
    @Persisted var x:Int = 0
    @Persisted var y:Int = 0
    @Persisted var red:Double = 0
    @Persisted var green:Double = 0
    @Persisted var blue:Double = 0
    @Persisted var opacicy:Double = 0
    @Persisted var timeIntervalSince1970:Double = 0
    @Persisted var ownerId:String = ""
    
    struct ThreadSafeModel : Codable, Hashable {
        static func == (left:DoteModel.ThreadSafeModel, right:DoteModel.ThreadSafeModel)-> Bool {
            return left.id == right.id
        }
        let id:String
        let x:Int
        let y:Int
        let canvasId:String
        let red:Double
        let green:Double
        let blue:Double
        let opacity:Double
        let date:Date
        let ownerId:String
        var color:Color {
            .init(red: red, green: green, blue: blue, opacity: opacity)
        }
    }
}

extension DoteModel {
    var date:Date {
        Date(timeIntervalSince1970: timeIntervalSince1970)
    }
    
    var color:Color {
        .init(.sRGBLinear,red: red, green: green, blue: blue, opacity: opacicy)
    }
    
    var threadSafeModel: ThreadSafeModel {        
        return .init(id: id, x:x, y:y,canvasId: canvasId, red: red, green: green, blue: blue, opacity: opacicy, date: Date(timeIntervalSince1970: timeIntervalSince1970), ownerId: ownerId)
    }
    
    var owner:ProfileModel? {
        return Realm.shared.object(ofType: ProfileModel.self, forPrimaryKey: ownerId)
    }
}
