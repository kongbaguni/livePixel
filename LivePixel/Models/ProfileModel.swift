//
//  ProfileModel.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/23.
//

import Foundation
import FirebaseFirestore

struct ProfileModel : Codable{
    let id:String
    var nickname:String? = nil
    var introduce:String? = nil
    var profileURL:String? = nil
    var updateDt:Date? = nil
    init(id: String, nickname: String? = nil, introduce: String? = nil, profileURL: String? = nil, updateDt: Date? = nil) {
        self.id = id
        self.nickname = nickname
        self.introduce = introduce
        self.profileURL = profileURL
        self.updateDt = updateDt
#if !targetEnvironment(simulator)
        if AuthManager.shared.userId == id {
            if self.profileURL == nil {
                self.profileURL = AuthManager.shared.auth.currentUser?.photoURL?.absoluteString
                print("photourl : \(profileURL ?? "없다")")
            }
        }
#endif
    }
    
    static func makeProfile(dic:[String:Any])->ProfileModel? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic)
            let decoder = JSONDecoder()
            return try decoder.decode(ProfileModel.self, from: jsonData)
        }
        catch {
            print("error: \(error.localizedDescription)")
        }
        return nil
    }
    
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
            return .init(id: id)
        }
#endif
        return nil
    }
    

    var dicValue:[String: Any]? {
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(self) else {
            return nil
        }
        
        guard let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            return nil
        }
                        
        return jsonDict
    }
    
    var collection:CollectionReference {
        return Firestore.firestore().collection("profile")
    }
    
    
    func getInfo(complete:@escaping(_ model:ProfileModel?, _ error:Error?)->Void){
       
        collection.document(id).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                print(data)
                complete(.makeProfile(dic: data),nil)
            }
            else {
                complete(nil,error)
            }
        }
    }
    
    mutating func updateData(data:[String:Any]) {
        self.nickname = data["nickname"] as? String
    }
    
    func update(complete:@escaping(_ error:Error?)->Void) {
        guard let value = dicValue else {
            return
        }
        collection.document(id).updateData(value) { error in
            if error != nil {
                collection.document(id).setData(value) { error in
                    
                }
            }
        }
    }
}
