//
//  UIImage-Extension.swift
//  Firebase-102
//
//  Created by Andrei Nagy on 2/15/17.
//  Copyright © 2017 Andrei Nagy. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func resized(width: CGFloat) -> UIImage? {
        let image = self
        let height = CGFloat(ceil(width/image.size.width * image.size.height))
        let canvasSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        image.draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
