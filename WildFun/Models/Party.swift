//
//  Party.swift
//  Firebase-102
//
//  Created by Andrei Nagy on 1/30/17.
//  Copyright © 2017 Andrei Nagy. All rights reserved.
//

import Foundation
import FirebaseDatabase
import UIKit

struct Party: FirebaseModel {
    let partyKey: String?
    let owner: String
    let description: String
    let guests: [String]?
    let photos: [String]?
    var firebaseReference: FIRDatabaseReference?
    
    init(owner: String, description: String, partyKey: String?) {
        self.owner = owner
        self.description = description
        self.guests = nil
        self.partyKey = partyKey
        self.photos = nil
    }
    
    init?(snapshot: FIRDataSnapshot) {
        if let snapshotValue = snapshot.value as? [String: Any],
            let owner = snapshotValue[FirebasePartiesKeys.owner.rawValue] as? String,
            let description = snapshotValue[FirebasePartiesKeys.description.rawValue] as? String
        {
            self.owner = owner
            self.description = description
            self.partyKey = snapshot.key
            
            self.guests = stringsArrayWithTrueKeys(snapshotValue: snapshotValue[FirebasePartiesKeys.guests.rawValue])
            self.photos = stringsArrayWithTrueKeys(snapshotValue: snapshotValue[FirebasePartiesKeys.photos.rawValue])
            
            self.firebaseReference = snapshot.ref
        } else {
            return nil
        }
    }
    
    func toDictionary() -> [String: Any] {
        return [
            FirebasePartiesKeys.owner.rawValue: self.owner,
            FirebasePartiesKeys.description.rawValue: self.description
        ]
    }
    
    func removeFromFirebase() {
        self.firebaseReference?.removeValue()
    }
    
    mutating func createInFirebase() {
        let reference = FIRDatabase.database().reference(withPath: FirebasePaths.parties.rawValue)
        if let key = self.partyKey {
            self.firebaseReference = reference.child(key)
        } else {
            self.firebaseReference = reference.childByAutoId()
        }
        self.firebaseReference?.setValue(self.toDictionary())
    }
    
    func addAttendee(uid: String) {
        let reference = createFirebaseReference(components: [FirebasePaths.parties.rawValue, FirebasePartiesKeys.guests.rawValue])
        reference?.setValue([uid: true])
    }
    
    func removeAttendee(uid: String) {
        let reference = createFirebaseReference(components: [FirebasePaths.parties.rawValue, FirebasePartiesKeys.guests.rawValue])
        reference?.setValue([uid: false])
    }
    
    func addPicture(key: String) {
        guard let partyKey = self.partyKey else {
            return
        }
        Party.addPicture(imageKey: key, partyKey: partyKey)
    }
    
    static func addPicture(imageKey: String, partyKey: String) {
        if let reference = createFirebaseReference(components: [Party.pathFor(key: partyKey), FirebasePartiesKeys.photos.rawValue, imageKey]) {
            reference.setValue(true)
        }
    }
    
    static func pathFor(key: String) -> String {
        return [FirebasePaths.parties.rawValue, key].joined(separator: FirebasePathSeparator)
    }
    
    static func pathForGuests(key: String) -> String {
        return [FirebasePaths.parties.rawValue,
                key,
                FirebasePartiesKeys.guests.rawValue].joined(separator: FirebasePathSeparator)
    }
}
