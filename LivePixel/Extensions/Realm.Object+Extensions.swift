//
//  Realm.Object+Extensions.swift
//  LivePixel
//
//  Created by Changyeol Seo on 2023/08/24.
//

import Foundation
import RealmSwift

extension Object {
    var dictionmaryValue:[String:Any] {
        var dictionary: [String: Any] = [:]
        for property in objectSchema.properties {
            let value = self[property.name]
            dictionary[property.name] = value
        }
        return dictionary
    }
}
