//
//  FirebaseConstants.swift
//  Firebase-102
//
//  Created by Andrei Nagy on 1/30/17.
//  Copyright © 2017 Andrei Nagy. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

let FirebasePathSeparator = "/"
let FirebasePhotosPath = "photos"
let FirebaseEmptyValue = "null"

enum FirebasePaths: String {
    case messages = "messages"
    case users = "users"
    case parties = "parties"
}

enum FirebaseMessagesKeys: String {
    case from = "from"
    case to = "to"
    case party = "party"
    case photo = "photo"
    case messageType = "messageType"
    case messageContent = "messageContent"
}

enum FirebaseUserKeys: String {
    case uid = "uid"
    case email = "email"
    case friends = "friends"
    case parties = "parties"
    case photos = "photos"
    
    case ownedParties = "ownedParties"
    case attendingParties = "attendingParties"
}

enum FirebasePartiesKeys: String {
    case guests = "guests"
    case photos = "photos"
    case description = "description"
    case owner = "owner"
}

func createFirebaseReference(components: [Any]?) -> FIRDatabaseReference? {
    if let path = firebasePath(components: components) {
        return FIRDatabase.database().reference(withPath: path)
    }
    return nil
}

func createFirebaseStorageReference(components: [Any]?) -> FIRStorageReference? {
    if let path = firebasePath(components: components) {
        let storage = FIRStorage.storage()
        let reference = storage.reference(withPath: path)
        return reference
    }
    return nil
}

fileprivate func firebasePath(components: [Any]?) -> String? {
    guard let components = components else {
        return nil
    }
    
    var strings = [String]()
    for thing in components {
        if let string = thing as? String {
            strings.append(string)
        }
        
        if let path = thing as? FirebasePaths {
            strings.append(path.rawValue)
        }
    }
    
    if strings.count > 0 {
        return strings.joined(separator: FirebasePathSeparator)
    }
    
    return nil
}

/* Converts a dictionary of keys and bools to an array of strings with "true" keys
 */
func stringsArrayWithTrueKeys(snapshotValue: Any?) -> [String]? {
    var result: [String]? = nil
    
    if let dict = snapshotValue as? [String: Bool] {
        
        var keys = [String]()
        for (key, value) in dict {
            if value == true {
                keys.append(key)
            }
        }
        
        if keys.count > 0 {
            result = keys
        } else {
            result = nil
        }
    }
    return result
}
