//
//  MainTableViewController.swift
//  Firebase-102
//
//  Created by Andrei Nagy on 2/4/17.
//  Copyright © 2017 Andrei Nagy. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MainTableViewController: UITableViewController {
    
    var currentUserReference: FIRDatabaseReference?
    var messagesReference: FIRDatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = CurrentUser(),
            let reference = createFirebaseReference(components: [FirebasePaths.messages, currentUser.uid]) {
            let path = currentUser.path()
            
            self.messagesReference = reference

            self.currentUserReference = FIRDatabase.database().reference(withPath: path)
            self.currentUserReference?.queryOrderedByKey().observe(.value, with: { snapshot in
                
                if let currentUser = User(snapshot: snapshot) {
                    
                    self.messagesReference?.queryOrderedByKey().observe(.value, with: { snapshot in
                        
                        var messages = [Message]()
                        for item in snapshot.children {
                            if let message = Message(snapshot: item as! FIRDataSnapshot) {
                                if message.to == currentUser.uid && message.isReply() {
                                    messages.append(message)
                                }
                            }
                        }
                        
                        self.applyMessages(messages: messages)
                    })
                }
            })
        }
    }
    
    deinit {
        self.messagesReference?.removeAllObservers()
        self.currentUserReference?.removeAllObservers()
    }
    
    func applyMessages(messages: [Message]) {
        for message in messages {
            if message.messageType == .partyInvite {
                self.applyPartyReply(message: message)
            } else if message.messageType == .friendRequest {
                self.applyFriendReply(message: message)
            }
        }
    }
    
    func applyPartyReply(message: Message) {
        if let currentUser = CurrentUser() {
            currentUser.addGuestFrom(message: message)
        }
        let alert = UIAlertController.withMessage(message: message.toDictionary().description)
        self.present(alert, animated: true, completion: nil)
    }
    
    func applyFriendReply(message: Message) {
        if let currentUser = CurrentUser() {
            currentUser.addFriendFrom(message: message)
        }
        let alert = UIAlertController.withMessage(message: message.toDictionary().description)
        self.present(alert, animated: true, completion: nil)
    }
}
