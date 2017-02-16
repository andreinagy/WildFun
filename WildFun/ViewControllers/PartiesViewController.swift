//
//  FirstViewController.swift
//  Firebase-102
//
//  Created by Andrei Nagy on 1/26/17.
//  Copyright © 2017 Andrei Nagy. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class PartiesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var userReference: FIRDatabaseReference?
    var partiesReferences = [FIRDatabaseReference]()
    
    var ownedParties = [Party]()
    var attendingParties = [Party]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.ownedParties = [Party]()
        self.attendingParties = [Party]()
        self.tableView.reloadData()
        
        if let currentUser = CurrentUser(),
            let r = createFirebaseReference(components: [currentUser.path()]) {
            
            self.userReference = r
            self.userReference?.queryOrderedByKey().observe(.value, with: { snapshot in
                self.updateFrom(snapshot: snapshot)
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.clearPartiesReferences()
        self.userReference?.removeAllObservers()
    }
    
    func updateFrom(snapshot: FIRDataSnapshot) {
        if let user = User(snapshot: snapshot) {
            
            self.clearPartiesReferences()
            
            self.ownedParties = [Party]()
            if let partiesDicts = user.ownedPartiesKeys {
                for key in partiesDicts.keys {
                    if let reference = createFirebaseReference(components: [FirebasePaths.parties.rawValue, key]) {
                        reference.queryOrderedByKey().observe(.value, with: { snapshot in
                            if let party = Party(snapshot: snapshot) {
                                self.ownedParties.append(party)
                                self.tableView.reloadData()
                            }
                        })
                        
                        self.partiesReferences.append(reference)
                    }
                }
            }
            
            self.attendingParties = [Party]()
            if let partiesDicts = user.attendingPartiesKeys {
                for key in partiesDicts.keys {
                    if let reference = createFirebaseReference(components: [FirebasePaths.parties.rawValue, key]) {
                        reference.queryOrderedByKey().observe(.value, with: { snapshot in
                            if let party = Party(snapshot: snapshot) {
                                self.attendingParties.append(party)
                                self.tableView.reloadData()
                            }
                        })
                        
                        self.partiesReferences.append(reference)
                    }
                }
            }
            
        }
    }
    
    func clearPartiesReferences() {
        for reference in self.partiesReferences {
            reference.removeAllObservers()
        }
        self.partiesReferences = [FIRDatabaseReference]()
    }
    
    @IBAction func returnFromPartyDescription(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? PartyDescriptionTableViewController {
            if let selectedrow = self.tableView.indexPathsForSelectedRows?[0] {
                
                if selectedrow.section == 0 {
                    viewController.selectedParty = self.ownedParties[selectedrow.row]
                    viewController.mode = .update
                }
                
                if selectedrow.section == 1 {
                    viewController.selectedParty = self.attendingParties[selectedrow.row]
                    viewController.mode = .readOnly
                }
            } else {
                viewController.mode = .create
            }
        }
    }
}

extension PartiesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = "Attending parties"
        if section == 0 {
            title = "Organized parties"
        }
        return title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.ownedParties.count
        }
        return self.attendingParties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let party = self.partyAt(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier", for: indexPath)
        cell.textLabel?.text = party.description
        cell.detailTextLabel?.text = party.owner
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let party = self.partyAt(indexPath: indexPath)
            party.removeFromFirebase()
            self.ownedParties.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    func partyAt(indexPath: IndexPath) -> Party {
        var parties = self.attendingParties
        if indexPath.section == 0 {
            parties = self.ownedParties
        }
        return parties[indexPath.row]
    }
}

extension PartiesViewController: UITableViewDelegate {
    
}

