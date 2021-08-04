//
//  Text Field.swift
//  All Pass
//
//  Created by Lam Nguyen on 7/5/21.
//

import Foundation
import UIKit

extension UITextField{
    
    /*
        @setLeftPaddingPoints
        Adds padding to the left side of the text
        -- amount: value of padding
     */
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
