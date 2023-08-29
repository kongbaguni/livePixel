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
    @Persisted var deleted:Bool = false
    @Persisted var width:Int = 16
    @Persisted var height:Int = 16
    @Persisted var offsetX:Int = 0
    @Persisted var offsetY:Int = 0
    
    struct ThreadSafeModel : Codable, Hashable {
        static func == (left:ThreadSafeModel, right:ThreadSafeModel)-> Bool {
            return left.id == right.id
        }
        let id:String
        let title:String
        let onwerId:String
        let updateDt:Double
        let deleted:Bool
        let width:Int
        let height:Int
        let offsetX:Int
        let offsetY:Int
        
        var updateDate:Date {
            return Date(timeIntervalSince1970: updateDt)
        }
        
        var deletedNow:Bool {
#if !targetEnvironment(simulator)
            return Realm.shared.object(ofType: CanvasModel.self, forPrimaryKey: id)?.deleted == true
#else
            return false
#endif
        }
        
        var dicValue:[String:Any]? {
            do {
                let jsondata =  try JSONEncoder().encode(self)
                let json = try JSONSerialization.jsonObject(with: jsondata) as? [String:Any]
                return json
            } catch {
                return nil
            }
        }
        
    }
}

extension CanvasModel {
    var threadSafeModel:ThreadSafeModel {
        return .init(id: id, title: title, onwerId: ownerId,  updateDt: updateDt, deleted: deleted, width:width, height: height, offsetX: offsetX, offsetY: offsetY)
    }
}
