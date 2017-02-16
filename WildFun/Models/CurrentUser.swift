//
//  CurrentUser.swift
//  Firebase-102
//
//  Created by Andrei Nagy on 2/4/17.
//  Copyright © 2017 Andrei Nagy. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import UIKit

struct CurrentUser {
    
    let uid: String
    
    init?() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return nil
        }
        self.uid = uid
    }

    func friendsPath() -> String {
        return [FirebasePaths.users.rawValue,
                self.uid,
                FirebaseUserKeys.friends.rawValue].joined(separator: FirebasePathSeparator)
    }
    
    func addFriend(uid: String, value: Bool) {
        if let path = CurrentUser()?.friendPath(uid: uid) {
            let reference = FIRDatabase.database().reference(withPath: path)
            reference.setValue(value)
        }
    }
    
    private func friendPath(uid: String) -> String {
        return [FirebasePaths.users.rawValue,
                self.uid,
                FirebaseUserKeys.friends.rawValue,
                uid].joined(separator: FirebasePathSeparator)
    }
    
    func addPicture(image: UIImage, firebasePhoto: Photo) {
        if let reference = firebasePhoto.storageReference() {
            
            if let resizedImage = image.resized(width: 300),
                let data = UIImagePNGRepresentation(resizedImage) {
                
                reference.put(data, metadata: Photo.metadata())
                
                if let reference = createFirebaseReference(components: [self.path(), FirebaseUserKeys.photos.rawValue, firebasePhoto.key]) {
                    reference.setValue(true)
                }
            }
        }
    }
    
    func path() -> String {
        return User.pathFor(uid: self.uid)
    }
    
    func setOwner(partyKey: String) {
        let reference = createFirebaseReference(components: [self.path(), FirebaseUserKeys.ownedParties.rawValue, partyKey])
        reference?.setValue(true)
    }
    
    func addAttendingParty(partyKey: String) {
        let reference = createFirebaseReference(components: [self.path(), FirebaseUserKeys.attendingParties.rawValue, partyKey])
        reference?.setValue(true)
    }
    
    func removeAttendingParty(partyKey: String) {
        let reference = createFirebaseReference(components: [self.path(), FirebaseUserKeys.attendingParties.rawValue, partyKey])
        reference?.setValue(false)
    }
    
    func addGuestFrom(message: Message) {
        var value = false
        if message.messageContent == .accept {
            value = true
        }
        
        if let partyKey = message.party {
            let path = Party.pathForGuests(key: partyKey)
            let reference = FIRDatabase.database().reference(withPath: path)
            reference.setValue([message.from: value])
        }
        
        message.removeFromFirebase()
    }
    
    func addFriendFrom(message: Message) {
        var value = false
        if message.messageContent == .accept {
            value = true
        }
        
        self.addFriend(uid: message.from, value: value)
        
        message.removeFromFirebase()
    }
}
