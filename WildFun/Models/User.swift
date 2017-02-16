//
//  User.swift
//  Firebase-102
//
//  Created by Andrei Nagy on 1/30/17.
//  Copyright © 2017 Andrei Nagy. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct User: FirebaseModel {
    let uid: String
    let email: String
    var firebaseReference: FIRDatabaseReference?
    let ownedPartiesKeys: [String: Any]?
    let attendingPartiesKeys: [String: Any]?
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
        self.ownedPartiesKeys = nil
        self.attendingPartiesKeys = nil
    }
    
    init?(snapshot: FIRDataSnapshot) {
        if let snapshotValue = snapshot.value as? [String: Any],
            let uid = snapshotValue[FirebaseUserKeys.uid.rawValue] as? String,
            let email = snapshotValue[FirebaseUserKeys.email.rawValue] as? String
        {
            self.uid = uid
            self.email = email
            
            self.ownedPartiesKeys = snapshotValue[FirebaseUserKeys.ownedParties.rawValue] as? [String: Any]
            self.attendingPartiesKeys = snapshotValue[FirebaseUserKeys.attendingParties.rawValue] as? [String: Any]
            
            self.firebaseReference = snapshot.ref
        } else {
            return nil
        }
    }
    
    func toDictionary() -> [String: Any] {
        return [
            FirebaseUserKeys.uid.rawValue: self.uid,
            FirebaseUserKeys.email.rawValue: self.email,
        ]
    }
    
    func removeFromFirebase() {
        self.firebaseReference?.removeValue()
    }
    
    mutating func createInFirebase() {
        let reference = FIRDatabase.database().reference(withPath: FirebasePaths.users.rawValue)
        self.firebaseReference = reference.child(self.uid)
        self.firebaseReference?.setValue(self.toDictionary())
    }
    
    static func pathFor(uid: String) -> String {
        return [FirebasePaths.users.rawValue, uid].joined(separator: FirebasePathSeparator)
    }
    
    func path() -> String {
        return User.pathFor(uid: self.uid)
    }
}
