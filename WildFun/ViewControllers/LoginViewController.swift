//
//  ViewController.swift
//  Task Burner
//
//  Created by Andrei Nagy on 10/17/16.
//  Copyright © 2016 weheartswift.com. All rights reserved.
//

import UIKit
import Firebase

let kUserLoggedInSegueIdentifier = "userLoggedIn"

class LoginViewController: UIViewController {
    
    /* @IBOutlets create references so strings can be read from
     the UITextFields
     */
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    /* Have a reference to the last signed in user to compare
     changes
     */
    weak var currentUser: FIRUser?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let auth = FIRAuth.auth() {
            
            /* Add a state change listener to firebase
             to get a notification if the user signed in.
            */
            auth.addStateDidChangeListener({ (auth, user) in
                if user != nil && user != self.currentUser {
                    self.currentUser = user
                    self.performSegue(withIdentifier: kUserLoggedInSegueIdentifier,
                                      sender: self)
                }
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let auth = FIRAuth.auth() {
            /* Following the balance principle in iOS,
             Stop listening to user state changes while not on screen.
            */
            auth.removeStateDidChangeListener(self)
        }
    }
    
    @IBAction func login() {
        if let email = self.emailField.text,
            let password = self.passwordField.text,
            let auth = FIRAuth.auth() {
            
            /* If both email and password fields are not empty,
             call firebase signin
            */
            auth.signIn(withEmail: email,
                        password: password)
        }
    }
    
    @IBAction func register() {
        if let email = self.emailField.text,
            let password = self.passwordField.text,
            let auth = FIRAuth.auth() {
            /* Note: creating a user automatically signs in.
            */
            auth.createUser(withEmail: email,
                            password: password) { user, error in
                                if error != nil {
                                    self.present(UIAlertController.withError(error: error as! NSError),
                                                 animated: true,
                                                 completion: nil)
                                } else {
                                    if let uid = FIRAuth.auth()?.currentUser?.uid {
                                        
                                        var user = User(uid: uid, email: email)
                                        user.createInFirebase()
                                    }
                                }
            }
        }
    }
    
    @IBAction func signOut(segue: UIStoryboardSegue) {
        /* When Sign out is pressed, and the task list controller closes,
         call Firebase sign out.
        */
        if let auth = FIRAuth.auth() {
            do {
                try auth.signOut()
            } catch {
                self.present(UIAlertController.withError(error: error as NSError),
                             animated: true,
                             completion: nil)
            }
        }
    }
}

