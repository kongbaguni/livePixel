//
//  FirestoreHelper.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/24.
//

import Foundation
import FirebaseFirestore
import RealmSwift

struct FirestoreHelper {
    fileprivate static let profileCollection:CollectionReference = Firestore.firestore().collection("profile")
    static func getProfile(id:String, complete:@escaping(_ error:Error?)->Void) {
        FirestoreHelper.profileCollection.document(id).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                print(data)
                do {
                    let realm = Realm.shared
                    try realm.write{
                        realm.create(ProfileModel.self, value: data, update: .all)
                    }
                    complete(nil)
                } catch {
                    complete(error)
                }
                return
            }
            complete(error)
        }
    }
    
    static func profileUpload(id:String,complete:@escaping(_ error:Error?)->Void) {
        guard let model = Realm.shared.object(ofType: ProfileModel.self, forPrimaryKey: id) else {
            return
        }
        let value = model.dictionmaryValue
        let id = id
        FirestoreHelper.profileCollection.document(id).updateData(value) { errorA in
            if errorA != nil {
                FirestoreHelper.profileCollection.document(id).setData(value) { errorB in
                    complete(errorB)
                }
                return
            }
            complete(errorA)
        }
    }


    
}
