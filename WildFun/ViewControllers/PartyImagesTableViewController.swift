//
//  PartyImagesTableViewController.swift
//  Firebase-102
//
//  Created by Andrei Nagy on 2/13/17.
//  Copyright © 2017 Andrei Nagy. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class PartyImagesTableViewController: UITableViewController {
    
    var selectedParty: Party?
    var partyReference: FIRDatabaseReference?
    
    @IBAction func addImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = CurrentUser(),
            let r = self.selectedParty?.firebaseReference {
            self.partyReference = r
            
            self.partyReference?.observe(.value, with: { snapshot in
                
                self.selectedParty = Party(snapshot: snapshot)
                self.tableView.reloadData()
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedParty?.photos?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        if let cell = cell as? ImageTableViewCell {
            
            if let key = self.selectedParty?.photos?[indexPath.row] {
                let firebaseImage = Photo(key: key)
                let reference = firebaseImage.storageReference()
                
                reference?.data(withMaxSize: 10 * 1024 * 1024) { data, error in
                    if (error != nil) {
                        print(error?.localizedDescription ?? "unknown error")
                    } else {
                        if let d = data {
                            cell.uiimageView.image = UIImage(data: d)
                        }
                    }
                }
            }
        }
        return cell
    }
}

extension PartyImagesTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let currentUser = CurrentUser(),
            let party = self.selectedParty {
            let firebaseImage = Photo(key: UUID().uuidString)
            currentUser.addPicture(image: chosenImage, firebasePhoto: firebaseImage)
            
            if (currentUser.uid != party.owner) {
                
            var message = Message(from: currentUser.uid,
                                  to: party.owner,
                                  party: party.partyKey,
                                  photo: firebaseImage.key,
                                  messageType: .imageUploaded,
                                  messageContent: .invite)
            message.createInFirebase()
                
                let alert = UIAlertController(title: nil,
                                              message: "Your photo will show up after the host will approve it",
                                              preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ok",
                                                 style: .default)
                alert.addAction(cancelAction)
                picker.dismiss(animated:true, completion: {
                    self.present(alert, animated: true, completion: nil)
                })
            } else {
                party.addPicture(key: firebaseImage.key)
                picker.dismiss(animated: true, completion: nil)
            }
        }
    }
}
