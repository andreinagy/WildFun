//
//  FirebaseModel.swift
//  Firebase-102
//
//  Created by Andrei Nagy on 2/4/17.
//  Copyright © 2017 Andrei Nagy. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol FirebaseModel {
    init?(snapshot: FIRDataSnapshot)
    func toDictionary() -> [String: Any]
    func removeFromFirebase()
    mutating func createInFirebase()
}
