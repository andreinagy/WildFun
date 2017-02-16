//
//  Image.swift
//  Firebase-102
//
//  Created by Andrei Nagy on 2/13/17.
//  Copyright © 2017 Andrei Nagy. All rights reserved.
//

import Foundation
import FirebaseStorage

struct Photo {
    let key: String
    
    static func metadata() -> FIRStorageMetadata {
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/png"
        return metadata
    }
    
    static func storageReference() -> FIRStorageReference? {
        let imageId = UUID().uuidString
        return createFirebaseStorageReference(components: [FirebasePhotosPath, imageId])
    }
    
    func storageReference() -> FIRStorageReference? {
        return createFirebaseStorageReference(components: [FirebasePhotosPath, self.key])
    }
}
