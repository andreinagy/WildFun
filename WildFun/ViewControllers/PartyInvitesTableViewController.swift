//
//  PartyInvitesTableViewController.swift
//  Firebase-102
//
//  Created by Andrei Nagy on 2/2/17.
//  Copyright © 2017 Andrei Nagy. All rights reserved.
//
import UIKit
import FirebaseDatabase
import FirebaseAuth

class PartyInvitesTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var reference: FIRDatabaseReference?
    var alreadySelectedUserIds: [String]?
    var items = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let currentUser = CurrentUser() {
            let path = currentUser.friendsPath()
            self.reference = FIRDatabase.database().reference(withPath: path)
            self.reference?.queryOrderedByKey().observe(.value, with: { snapshot in
                
                self.items = [User]()
                for item in snapshot.children {
                    let uid = (item as! FIRDataSnapshot).key
                    let friendPath = User.pathFor(uid: uid)
                    let reference = FIRDatabase.database().reference(withPath: friendPath)
                    reference.queryOrderedByKey().observe(.value, with: { snapshot in
                        if let user = User(snapshot: snapshot) {
                            self.items.append(user)
                            self.tableView.reloadData()
                        }
                    })
                }
            })
        }
    }
    
    deinit {
        self.reference?.removeAllObservers()
        for user in self.items {
            user.firebaseReference?.removeAllObservers()
        }
    }
    
    func selectedFriends() -> [User]? {
        if let indexPaths = self.tableView.indexPathsForSelectedRows {
            let indexes = indexPaths.map({ indexPath -> Int in
                return indexPath.row
            })
            var users = [User]()
            for index in indexes {
                users.append(self.items[index])
            }
            return users
        }
        return nil
    }
}

extension PartyInvitesTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier", for: indexPath)
        let user = self.items[indexPath.row]
        cell.textLabel?.text = user.email
        cell.detailTextLabel?.text = user.uid
        
        let selected = self.alreadySelectedUserIds?.filter {
            $0 == user.uid
        }
        if selected != nil {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        return cell
    }
}

extension PartyInvitesTableViewController: UITableViewDelegate {
    
}
