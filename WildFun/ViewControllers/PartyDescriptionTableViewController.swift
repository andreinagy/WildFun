//
//  PartyDescriptionTableViewController.swift
//  Firebase-102
//
//  Created by Andrei Nagy on 2/2/17.
//  Copyright © 2017 Andrei Nagy. All rights reserved.
//

import UIKit

enum ViewControllerMode: String {
    case create
    case update
    case readOnly
}

class PartyDescriptionTableViewController: UITableViewController {

    @IBOutlet weak var inviteFriendsCell: UITableViewCell!
    @IBOutlet weak var createNavigationItem: UIBarButtonItem!
    
    var mode: ViewControllerMode = .readOnly
    var selectedFriends: [User]?
    var selectedParty: Party?
    var selectedImages: [UIImage]?
    
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBAction func navigationBarButtonPressed(_ sender: Any) {
        let viewController = self
        if let description = viewController.descriptionTextField.text,
            let currentUser = CurrentUser() {
            
            switch viewController.mode {
            case .create :
                var party = Party(owner: currentUser.uid, description: description, partyKey: nil)
                party.createInFirebase()
                if let key = party.firebaseReference?.key {
                    currentUser.setOwner(partyKey: key)
                } else {
                    fatalError("Party key should exist")
                }
                
                if let friends = viewController.selectedFriends {
                    
                    for friend in friends {
                        var message = Message(from: currentUser.uid,
                                              to: friend.uid,
                                              party: party.firebaseReference?.key,
                                              photo: nil,
                                              messageType: .partyInvite,
                                              messageContent: .invite)
                        message.createInFirebase()
                    }
                }
                
            case .update:
                if let party = viewController.selectedParty {
                    var updatedParty = Party(owner: currentUser.uid, description: description, partyKey: party.partyKey)
                    updatedParty.createInFirebase()
                    
                    if let friends = viewController.selectedFriends {
                        
                        for friend in friends {
                            var message = Message(from: currentUser.uid,
                                                  to: friend.uid,
                                                  party: party.firebaseReference?.key,
                                                  photo: nil,
                                                  messageType: .partyInvite,
                                                  messageContent: .invite)
                            message.createInFirebase()
                        }
                    }
                }
                
            default: break
                //            case .readOnly:
                
            }
        }

        self.performSegue(withIdentifier: "returnToPartiesSegue", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let p = self.selectedParty {
            self.descriptionTextField.text = p.description
        }
        
        switch self.mode {
        case .create:
            break
        case .update:
            self.createNavigationItem.title = "Update"
        default: // readOnly
            self.navigationItem.rightBarButtonItem = nil
            self.descriptionTextField.isUserInteractionEnabled = false
            self.navigationItem.title = "Party (\(self.mode.rawValue))"
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "Images" {
            if self.selectedParty == nil {
                let alert = UIAlertController.withMessage(message: "Please select an existing party first")
                self.present(alert, animated: true, completion: nil)
                self.tableView.reloadData()
                return false
            }
        }
        
        if identifier == "inviteFriends" && self.mode == .readOnly {
            let alert = UIAlertController.withMessage(message: "You can't invite friends because you are not the host of this party.")
            self.present(alert, animated: true, completion: nil)
            self.tableView.reloadData()
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? PartyInvitesTableViewController {
            viewController.alreadySelectedUserIds = self.selectedParty?.guests
        }
        
        if let viewController = segue.destination as? PartyImagesTableViewController {
            viewController.selectedParty = self.selectedParty
        }
    }
    
    @IBAction func addInvitedFriends(segue: UIStoryboardSegue) {
        if let viewController = segue.source as? PartyInvitesTableViewController {
            self.selectedFriends = viewController.selectedFriends()
        }
    }
    
    @IBAction func returnFromImages(segue: UIStoryboardSegue) {
    }
}
