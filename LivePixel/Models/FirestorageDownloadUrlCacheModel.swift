//
//  FirestoreageCacheModel.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/25.
//

import Foundation
import RealmSwift

class FirestorageDownloadUrlCacheModel : Object{
    @Persisted(primaryKey: true) var id:String = ""
    @Persisted var url:String = ""
    @Persisted var updateDt:Date = Date()
}

extension FirestorageDownloadUrlCacheModel {
    var isNeedRefresh:Bool {
        let now = Date()
        return now.timeIntervalSince1970 - updateDt.timeIntervalSince1970 > 86400
    }

    
    static func reg(id:String,url:String)->Error? {
        let data:[String:Any] = [
            "id":id,
            "url":url,
            "updateDt":Date()
        ]
        do {
            let realm = Realm.shared
            realm.beginWrite()
            realm.create(FirestorageDownloadUrlCacheModel.self, value: data, update: .all)
            try realm.commitWrite()
        } catch {
            return error
        }
        return nil
    }
    
    static func get(id:String)->FirestorageDownloadUrlCacheModel? {
        if let data = Realm.shared.object(ofType: FirestorageDownloadUrlCacheModel.self, forPrimaryKey: id) {
            if !data.isNeedRefresh {
                return data
            }
        }
        return nil
        
    }
}


