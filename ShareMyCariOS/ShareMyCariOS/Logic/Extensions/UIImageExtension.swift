//
//  UIImageExtension.swift
//  ShareMyCariOS
//
//  Created by Bas Buijsen on 01/02/2022.
//

import Foundation
import UIKit
import SwiftUI

extension UIImage {
    func toString() -> String {
        let image = imageWithoutBaseline()
        return image.jpegData(compressionQuality: 0.1)?.base64EncodedString() ?? ""
    }
}

extension String {
    func toImage() -> UIImage {
        if self.description == "tesla" {
            return UIImage(named: "tesla")!
        }
        let imageData = Data.init(base64Encoded: self.description, options: .init(rawValue: 0))
        let image = UIImage(data: imageData!)
        return image!
    }
}
