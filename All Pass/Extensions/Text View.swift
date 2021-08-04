//
//  Text View.swift
//  All Pass
//
//  Created by Lam Nguyen on 7/9/21.
//

import Foundation
import UIKit

extension UITextView{
    
    /*
        @setLeftPaddingPoints
        Adds some left padding to the text view
     */
    func setLeftPaddingPoints(){
        self.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 4, right: 4)
    }
}
