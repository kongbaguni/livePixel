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
    //MARK: - profile
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

    //MARK: - canvas
    fileprivate static let canvasCollection:CollectionReference = Firestore.firestore().collection("canvas")
    
    static func makeCanvas(title:String, complete:@escaping(_ error:Error?)->Void) {
        guard let ownerid = AuthManager.shared.userId else {
            return
        }
        let now = Date().timeIntervalSince1970
        canvasCollection.addDocument(data: [
            "title":title,
            "ownerId":ownerid,
            "updateDt":now
        ]) { error in
            complete(error)
        }        
    }

    static func getCanvasList(complete:@escaping(_ list:[CanvasModel.ThreadSafeModel], _ error:Error?)->Void) {
        var query = canvasCollection.order(by: "updateDt", descending: true)
        if let lastSyncDateTime = Realm.shared.objects(CanvasModel.self).sorted(byKeyPath: "updateDt").last?.updateDt {
            query = query.whereField("updateDt", isGreaterThan: lastSyncDateTime)
        }
                 
        query.getDocuments { snapshot, error in
            let realm = Realm.shared
            var result:[CanvasModel.ThreadSafeModel] = []
            do {
                realm.beginWrite()
                for doc in snapshot?.documents ?? [] {
                    var data = doc.data()
                    data["id"] = doc.documentID
                    print(data)
                    let model = realm.create(CanvasModel.self, value: data, update: .all)
                    if model.deleted == false {
                        result.append(model.threadSafeModel)
                    }
                }
                try realm.commitWrite()
                
                complete(result,error)
            }
            catch {
                complete(result,error)
            }
        }
    }
    
//    static func editCanvas(data:CanvasModel.ThreadSafeModel, complete:@escaping(_ error:Error?)->Void) {
//        guard let dic = data.dicValue else {
//            return
//        }
//        canvasCollection.document(data.id).updateData(dic) { error in
//            if error == nil {
//                let realm = Realm.shared
//                realm.beginWrite()
//                realm.create(CanvasModel.self, value: dic, update: .all)
//                try! realm.commitWrite()
//            }
//            complete(error)
//        }
//    }
    
    static func deleteCanvas(canvasId:String, complete:@escaping(_ error:Error?)->Void) {
        var data:[String:Any] = [
            "deleted":true,
            "updateDt":Date().timeIntervalSince1970
        ]
        
        canvasCollection.document(canvasId).updateData(data) { error in
            if error == nil {
                data["id"] = canvasId
                let realm = Realm.shared
                realm.beginWrite()
                realm.create(CanvasModel.self, value: data, update: .modified)
                try! realm.commitWrite()
            }
            complete(error)
        }
    }
}
