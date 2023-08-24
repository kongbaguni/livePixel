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
    @Persisted var profileURL:String = ""
    @Persisted var updateDt:Double = Date().timeIntervalSince1970
}


// sync Firebase
extension ProfileModel {
    var isMe:Bool {
#if !targetEnvironment(simulator)
        return id == AuthManager.shared.userId
#else
        return false
#endif
    }
    
    static var current:ProfileModel? {
#if !targetEnvironment(simulator)
        if let id = AuthManager.shared.userId {
            return try? Realm().object(ofType: ProfileModel.self, forPrimaryKey: id)
        }
#endif
        return nil
    }
        
    
    func updateData(data:[String:Any])->Error? {
#if !targetEnvironment(simulator)
        do {
            let realm = try Realm()
            try realm.write{
                realm.create(ProfileModel.self,value: data,update: .modified)
            }
        } catch {
            return error
        }
#endif 
        return nil
    }
    
    func getProfileUrl() {
        let id = id
        FirebaseStorageHelper.shared.getDownloadURL(uploadPath: .profileImage, id: id) { url, error in
            if let url = url {
                do {
                    let realm = try Realm()
                    realm.beginWrite()
                    realm.create(ProfileModel.self, value: ["id":id, "profileURL":url.absoluteString], update: .modified)
                    try realm.commitWrite()
                    
                } catch {
                    
                }
            }
        }
    }
}
