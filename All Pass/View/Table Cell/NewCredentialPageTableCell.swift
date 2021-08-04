//
//  NewCredentialPageTableCell.swift
//  All Pass
//
//  Created by Lam Nguyen on 6/26/21.
//

import UIKit

class NewCredentialPageTableCell: viewInfoPageTableCell {
    
    //When the "copy" button is clicked, then generate a password according to the settings
    override func copyToBoard() {
        let passwordVC = PasswordGeneratorPageVC()
        infoLabelTF.text = passwordVC.createPassword(lower: password.savedSettings[0].lowerCase,
                                                    upper: password.savedSettings[0].upperCase,
                                                    numbers: password.savedSettings[0].numbers,
                                                    specialChar: password.savedSettings[0].specialChar,
                                                    length: password.savedSettings[0].length)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        copyButton.frame = CGRect(x: contentView.frame.size.width - 80,
                                  y: self.contentView.frame.size.height / 2 + 8,
                                  width: 100,
                                  height: contentView.frame.size.height / 4)
        
        let yPadding = self.contentView.frame.size.height / 11.4829929897
        infoLabelTF.frame = CGRect(x: 12,
                                   y: self.contentView.frame.size.height / 2 - yPadding + 6,
                                   width: contentView.frame.size.width - 23,
                                   height: contentView.frame.size.height / 2 + 3)
        
        
    }
}

