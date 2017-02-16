//
//  SecondViewController.swift
//  Firebase-102
//
//  Created by Andrei Nagy on 1/26/17.
//  Copyright © 2017 Andrei Nagy. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class FriendsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var reference: FIRDatabaseReference?
    var items = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let currentUser = CurrentUser() {
            let path = currentUser.friendsPath()
            print(path)
            self.reference = FIRDatabase.database().reference(withPath: path)
            self.reference?.queryOrderedByKey().observe(.value, with: { snapshot in
                
                self.items = [User]()
                for item in snapshot.children {
                    let uid = (item as! FIRDataSnapshot).key
                    let friendPath = User.pathFor(uid: uid)
                    print(friendPath)
                    let reference = FIRDatabase.database().reference(withPath: friendPath)
                    reference.queryOrderedByKey().observe(.value, with: { snapshot in
                        if let user = User(snapshot: snapshot) {
                            self.items.append(user)
                            self.tableView.reloadData()
                            reference.removeAllObservers()
                        }
                    })
                }
            })
        }
    }
    
    deinit {
        self.reference?.removeAllObservers()
    }
    
    @IBAction func sendFriendRequest(segue: UIStoryboardSegue) {
        if let addFriend = segue.source as? AddFriendTableViewController,
            let address = addFriend.emailAddressTextField.text,
            let currentUser = CurrentUser() {
            
            let path = FirebasePaths.users.rawValue
            let usersReference = FIRDatabase.database().reference(withPath: path)
            usersReference.queryOrderedByKey().observe(.value, with: { snapshot in
                
                var users = [User]()
                for item in snapshot.children {
                    if let user = User(snapshot: item as! FIRDataSnapshot) {
                        users.append(user)
                    }
                }
                
                for user in users {
                    if user.email == address {
                        // create a message.
                        var newMessage = Message(from: currentUser.uid,
                                                 to: user.uid,
                                                 party: nil,
                                                 photo: nil,
                                                 messageType: .friendRequest,
                                                 messageContent: .invite)
                        newMessage.createInFirebase()
                    }
                }
                usersReference.removeAllObservers()
            })
        }
    }
}

extension FriendsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier", for: indexPath)
        let user = self.items[indexPath.row]
        cell.textLabel?.text = user.email
        cell.detailTextLabel?.text = user.uid
        return cell
    }
}

extension FriendsViewController: UITableViewDelegate {
    
}
