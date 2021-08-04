//
//  Color.swift
//  AutofillProvider
//
//  Created by Lam Nguyen on 7/8/21.
//

import Foundation
import UIKit

extension UIColor{
    convenience init(red: Int, green: Int, blue: Int){
        let redV = CGFloat(red) / 255.0
        let greenV = CGFloat(green) / 255.0
        let blueV = CGFloat(blue) / 255.0
        
        self.init(red: redV, green: greenV, blue: blueV, alpha: 1.0)
    }
}
