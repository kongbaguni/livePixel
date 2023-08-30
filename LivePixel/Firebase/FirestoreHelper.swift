//
//  FirestoreHelper.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/24.
//

import Foundation
import FirebaseFirestore
import RealmSwift
import SwiftUI

extension Notification.Name {
    static let canvasDidDeleted = Notification.Name("cnavasDidDeleted_observer")
    static let canvasDidCreated = Notification.Name("canvasDidCreated_observer")
    static let doteDidCreated = Notification.Name("doteDidCreated_observer")
}
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
    
    static func makeCanvas(title:String, width:Int, height:Int, offset:(Int,Int),  complete:@escaping(_ error:Error?)->Void) {
        guard let ownerid = AuthManager.shared.userId else {
            return
        }
        let now = Date().timeIntervalSince1970
        let ref = canvasCollection.addDocument(data: [
            "title":title,
            "ownerId":ownerid,
            "updateDt":now,
            "width":width,
            "height":height,
            "offsetX":offset.0,
            "offsetY":offset.1,
        ]) { error in
            complete(error)
        }
        NotificationCenter.default.post(name: .canvasDidCreated, object: ref.documentID)
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
            NotificationCenter.default.post(name: .canvasDidDeleted, object: canvasId)
        }
    }
    
    
    fileprivate static let doteCollection:CollectionReference = Firestore.firestore().collection("dotes")

    static func getDotes(canvasId:String, complete:@escaping(_ list:[DoteModel.ThreadSafeModel], _ error:Error?)->Void) {
        let realm = Realm.shared
        let lastDote = realm.objects(DoteModel.self).filter("canvasId = %@", canvasId)
            .sorted(byKeyPath: "timeIntervalSince1970", ascending: true).last
        let sub = doteCollection.document(canvasId).collection("datas")
        sub
            .whereField("timeIntervalSince1970", isGreaterThan: lastDote?.timeIntervalSince1970 ?? 0)
            .getDocuments { snapShot, error in
                realm.beginWrite()
                var dotes:[DoteModel.ThreadSafeModel] = []
                for doc in snapShot?.documents ?? [] {
                    var data = doc.data()
                    data["id"] = doc.documentID
                    let model = realm.create(DoteModel.self, value: data, update: .all)
                    dotes.append(model.threadSafeModel)
                }
                try! realm.commitWrite()
                complete(dotes, error)
                NotificationCenter.default.post(name: .doteDidCreated, object: [dotes])
            }

    }
    static func makeDote(canvasId:String, position:(Int,Int), size:Int, color:Color) {
        guard let uid = AuthManager.shared.userId else {
            return
        }
        let realm = Realm.shared
        
        let cicolor = color.ciColor
        
        var data:[String:Any] = [
            "canvasId":canvasId,
            "x":position.0,
            "y":position.1,
            "red":Double(cicolor.red),
            "green":Double(cicolor.green),
            "blue":Double(cicolor.blue),
            "opacicy":Double(cicolor.alpha),
            "ownerId":uid,
            "size":size,
            "timeIntervalSince1970":Date().timeIntervalSince1970,
        ]
        print("""
              ci color --------
              red \(cicolor.red)
              green \(cicolor.green)
              blue \(cicolor.blue)
              alpha \(cicolor.alpha)
              
            data :
            red \(data["red"] as? Double ?? 0)
            green \(data["green"] as? Double ?? 0)
            blue \(data["blue"] as? Double ?? 0)
            alpha : \(data["opacicy"] as? Double ?? 0)
        """)
        print()
        if cicolor.alpha == 0 {
            abort()
        }
        let sub = doteCollection.document(canvasId).collection("datas")

        getDotes(canvasId: canvasId) { list, error in
            let ref = sub.addDocument(data: data) { error in
                
            }
            data["id"] = ref.documentID
            try! realm.write {
                let model = realm.create(DoteModel.self, value: data, update: .all)
            
                NotificationCenter.default.post(name: .doteDidCreated, object: model.threadSafeModel)
            }
        }
    }
}
