//
//  Realm+Extensions.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/24.
//

import Foundation
import RealmSwift

extension Realm {
    static var shared:Realm {
        let fileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.net.kongbaguni.share")!
            .appendingPathComponent("data.realm")
        let config = Realm.Configuration(fileURL: fileURL,
                                         schemaVersion:12) { migration, oldSchemaVersion in
            
        }
        
        return try! Realm(configuration: config)
    }
}
