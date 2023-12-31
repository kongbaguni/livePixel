//
//  ProfileModel.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/23.
//

import Foundation
import RealmSwift
import FirebaseFirestore

class ProfileModel : Object{
    @Persisted(primaryKey: true) var id:String = ""
    @Persisted var nickname:String = ""
    @Persisted var introduce:String = ""
    @Persisted var updateDt:Double = Date().timeIntervalSince1970
}


// sync Firebase
extension ProfileModel {
    var isMe:Bool {
        return id == AuthManager.shared.userId
    }
    
    static var current:ProfileModel? {
        if let id = AuthManager.shared.userId {
            return Realm.shared.object(ofType: ProfileModel.self, forPrimaryKey: id)
        }
        return nil
    }
        
    
    func updateData(data:[String:Any])->Error? {
        do {
            let realm = Realm.shared
            try realm.write{
                realm.create(ProfileModel.self,value: data,update: .modified)
            }
        } catch {
            return error
        }
        return nil
    }
    
}
