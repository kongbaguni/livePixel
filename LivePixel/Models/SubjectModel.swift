//
//  SubjectModel.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/30.
//

import Foundation
import RealmSwift

class SubjectModel : Object {
    @Persisted(primaryKey: true) var id:String = ""
    @Persisted var title:String = ""
    @Persisted var width:Int = 1024
    @Persisted var height:Int = 1024
    @Persisted var ownerId:String = ""
    @Persisted var updateTimeIntervalSince1970:Double = 0
    
    struct ThreadSafeModel : Codable, Hashable {
        static func == (left:ThreadSafeModel, right:ThreadSafeModel)->Bool {
            return left.id == right.id
        }
        let id:String
        let title:String
        let width:Int
        let height:Int
        let ownerId:String
        let updateTimeIntervalSince1970:TimeInterval
    }
}

extension SubjectModel {
    var threadSafeModel: ThreadSafeModel {
        .init(id: id,
              title: title,
              width: width,
              height: height,
              ownerId: ownerId,
              updateTimeIntervalSince1970: updateTimeIntervalSince1970)
    }
    
    var updateDate:Date {
        return .init(timeIntervalSince1970: updateTimeIntervalSince1970)
    }
    
    var owner:ProfileModel? {
        return Realm.shared.object(ofType: ProfileModel.self, forPrimaryKey: ownerId)
    }
}
