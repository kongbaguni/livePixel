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
    @Persisted var size:Int = 1
    @Persisted var drawType:String = "circle"
    @Persisted var blendModeRawValue:Int32 = 0
    enum DrawType : String, CaseIterable {
        case circle = "circle"
        case horizontalLine = "horizontalLine"
        case verticalLine = "verticalLine"
        case square = "square"
    }
    
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
        let size:Int
        let drawType:String
        let blendModeRawValue:Int32
        var color:Color {
            .init(red: red, green: green, blue: blue, opacity: opacity)
        }
        var drawTypeValue:DrawType {
            .init(rawValue: drawType) ?? .circle
        }
        var blendMode:GraphicsContext.BlendMode {
            .init(rawValue: blendModeRawValue)
        }
        var blendModeTextValue:Text {
            Text("")
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
        return .init(id: id, x:x, y:y,canvasId: canvasId, red: red, green: green, blue: blue, opacity: opacicy, date: Date(timeIntervalSince1970: timeIntervalSince1970), ownerId: ownerId, size:size, drawType: drawType, blendModeRawValue: blendModeRawValue)
    }
    
    var owner:ProfileModel? {
        return Realm.shared.object(ofType: ProfileModel.self, forPrimaryKey: ownerId)
    }
    
    var drawTypeValue:DrawType {
        .init(rawValue: drawType) ?? .circle
    }
    
    var blendMode:GraphicsContext.BlendMode {
        .init(rawValue: blendModeRawValue)
    }
    
    static func limitedResult(canvasId:String, limit:Int)->ReversedCollection<Slice<Results<DoteModel>>> {
        let result = Realm.shared.objects(DoteModel.self).filter("canvasId = %@", canvasId)
            .sorted(byKeyPath: "timeIntervalSince1970", ascending: false)
            .prefix(limit)
            .reversed()
        return result
    }
}
