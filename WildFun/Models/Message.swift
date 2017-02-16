//
//  Message.swift
//  Firebase-102
//
//  Created by Andrei Nagy on 1/30/17.
//  Copyright © 2017 Andrei Nagy. All rights reserved.
//

import Foundation
import FirebaseDatabase

enum MessageType: String {
    case invalid = "invalid"
    case friendRequest = "friend_request"
    case partyInvite = "party_invite"
    case imageUploaded = "image_uploaded"
}

enum MessageContent: String {
    case invalid = "invalid"
    case invite = "invite"
    case accept = "accept"
    case refuse = "refuse"
}

struct Message: FirebaseModel {
    let from: String
    let to: String
    let party: String?
    let photo: String?
    let messageType: MessageType
    let messageContent: MessageContent
    var firebaseReference: FIRDatabaseReference?
    
    init(from: String, to: String, party: String?, photo: String?, messageType: MessageType, messageContent: MessageContent) {
        self.from = from
        self.to = to
        self.party = party
        self.photo = photo
        self.messageType = messageType
        self.messageContent = messageContent
        self.firebaseReference = nil
    }
    
    init?(snapshot: FIRDataSnapshot) {
        if let snapshotValue = snapshot.value as? [String: Any],
            let from = snapshotValue[FirebaseMessagesKeys.from.rawValue] as? String,
            let to = snapshotValue[FirebaseMessagesKeys.to.rawValue] as? String,
            let type = snapshotValue[FirebaseMessagesKeys.messageType.rawValue] as? String,
            let content = snapshotValue[FirebaseMessagesKeys.messageContent.rawValue] as? String
        {
            self.from = from
            self.to = to
            let partyKey = snapshotValue[FirebaseMessagesKeys.party.rawValue] as? String
            self.party = partyKey == FirebaseEmptyValue ? nil : partyKey
            let photoKey = snapshotValue[FirebaseMessagesKeys.photo.rawValue] as? String
            self.photo = photoKey == FirebaseEmptyValue ? nil : photoKey
            self.messageType = MessageType(rawValue: type) ?? .invalid
            self.messageContent = MessageContent(rawValue: content) ?? .invalid
            self.firebaseReference = snapshot.ref
        } else {
            return nil
        }
    }
    
    func toDictionary() -> [String: Any] {
        return [
            FirebaseMessagesKeys.from.rawValue: self.from,
            FirebaseMessagesKeys.to.rawValue: self.to,
            FirebaseMessagesKeys.party.rawValue: self.party ?? FirebaseEmptyValue,
            FirebaseMessagesKeys.photo.rawValue: self.photo ?? FirebaseEmptyValue,
            FirebaseMessagesKeys.messageType.rawValue: self.messageType.rawValue,
            FirebaseMessagesKeys.messageContent.rawValue: self.messageContent.rawValue,
        ]
    }
    
    func isReply() -> Bool {
        return self.messageContent == .accept || self.messageContent == .refuse
    }
    
    func removeFromFirebase() {
        self.firebaseReference?.removeValue()
    }
    
    mutating func createInFirebase() {
        guard let reference = createFirebaseReference(components: [FirebasePaths.messages, self.to]) else {
            fatalError("Cant' create message path")
        }
        self.firebaseReference = reference.childByAutoId()
        self.firebaseReference?.setValue(self.toDictionary())
    }
}
