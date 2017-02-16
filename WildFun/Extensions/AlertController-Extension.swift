//
//  AlertController-Extension.swift
//  Task Burner
//
//  Created by Andrei Nagy on 10/19/16.
//  Copyright © 2016 weheartswift.com. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    
    static func withError(error: NSError) -> UIAlertController {
        let alert = UIAlertController(title: "Error",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok",
                                         style: .default)
        alert.addAction(cancelAction)
        return alert
    }
    
    static func withMessage(message: String) -> UIAlertController {
        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok",
                                         style: .default)
        alert.addAction(cancelAction)
        return alert
    }
}
