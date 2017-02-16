//
//  MessagesViewController.swift
//  Firebase-102
//
//  Created by Andrei Nagy on 1/30/17.
//  Copyright © 2017 Andrei Nagy. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MessagesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var messagesReference: FIRDatabaseReference?
    var items = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = CurrentUser(),
            let r = createFirebaseReference(components: [FirebasePaths.messages, currentUser.uid]) {
            
            self.messagesReference = r
            self.messagesReference?.queryOrderedByKey().observe(.value, with: { snapshot in
                
                var items = [Message]()
                
                for item in snapshot.children {
                    if let p = Message(snapshot: item as! FIRDataSnapshot) {
                        items.append(p)
                    }
                }
                
                self.items = items
                self.tableView.reloadData()
            })
        }
    }
    
    deinit {
        self.messagesReference?.removeAllObservers()
    }
}

extension MessagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier", for: indexPath)
        let message = self.items[indexPath.row]
        cell.textLabel?.text = message.from
        cell.detailTextLabel?.text = message.messageType.rawValue
        return cell
    }
}

extension MessagesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let message = self.items[indexPath.row]
        if message.isReply() {
            let alert = UIAlertController(title: nil,
                                          message: "This message was already replied",
                                          preferredStyle: .alert)
            
            let acceptAction = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(acceptAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let alertMessage = self.alertMessageFor(message: message)
        let alert = UIAlertController(title: "Reply",
                                      message: alertMessage,
                                      preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { action in
            self.acceptAction(message: message)
        }
        
        alert.addAction(acceptAction)
        
        let refuseAction = UIAlertAction(title: "Refuse", style: .default) { action in
            self.refuseAction(message: message)
        }
        alert.addAction(refuseAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension MessagesViewController {
    
    func alertMessageFor(message: Message) -> String {
        var alertMessage = "Unknown message type"
        if message.messageType == .friendRequest {
            alertMessage = "Do you accept the request from \(message.from)?"
        }
        
        if message.messageType == .partyInvite {
            if let p = message.party {
                alertMessage = "Will you attend the \(p.description) party?"
            }
        }
        
        if message.messageType == .imageUploaded {
            if let p = message.party {
                alertMessage = "Do you want to add the photo from \(message.from) to the party \(p)?"
            }
        }
        return alertMessage
    }
    
    func acceptAction(message: Message) {
        message.removeFromFirebase()
        
        if message.messageType == .friendRequest {
            
            if let currentUser = CurrentUser() {
                currentUser.addFriend(uid: message.from, value: true)
                
                var reply = Message(from: message.to,
                                    to: message.from,
                                    party: message.party,
                                    photo: nil,
                                    messageType: message.messageType,
                                    messageContent: .accept)
                reply.createInFirebase()
            }
        }
        
        if message.messageType == .partyInvite {
            if let currentUser = CurrentUser(),
                let key = message.party {
                currentUser.addAttendingParty(partyKey: key)
                
                var reply = Message(from: message.to,
                                    to: message.from,
                                    party: message.party,
                                    photo: nil,
                                    messageType: message.messageType,
                                    messageContent: .accept)
                reply.createInFirebase()
            }
        }
        
        if message.messageType == .imageUploaded {
            if let photo = message.photo,
                let party = message.party {
                Party.addPicture(imageKey: photo, partyKey: party)
            }
        }
    }
    
    func refuseAction(message: Message) {
        message.removeFromFirebase()
        
        if message.messageType == .friendRequest {
            var reply = Message(from: message.to,
                                to: message.from,
                                party: message.party,
                                photo: nil,
                                messageType: message.messageType,
                                messageContent: .refuse)
            reply.createInFirebase()
            
        } else if message.messageType == .partyInvite {
            if let currentUser = CurrentUser(),
                let key = message.party {
                currentUser.addAttendingParty(partyKey: key)
            }
        }
    }
}
