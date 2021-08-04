//
//  ViewReminderPageTableCell.swift
//  All Pass
//
//  Created by Lam Nguyen on 7/9/21.
//

import Foundation
import UIKit

class ViewReminderPageTableCell: UITableViewCell {
    
    let imageV = UIImageView()
    let titleLabel = UILabel()
    let infoLabel = UILabel()
    let copyButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //Add the assets to the view
        contentView.addSubview(imageV)
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(copyButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageV.frame =          CGRect(x: 3,                                                        //Displacement from the left
                                       y: 10,                                                       //Displacement from the top
                                       width: 38,                                                   //Width is size of the cell
                                       height: contentView.frame.size.height - 16)                  //Height is half of that of the cell
        
        titleLabel.frame =          CGRect(x: 53,
                                           y: 0,
                                           width: contentView.frame.size.width - 40,
                                           height: contentView.frame.size.height / 2)        
        
        infoLabel.frame =           CGRect(x: 53,
                                           y: contentView.frame.size.height / 2 - 8,
                                           width: contentView.frame.size.width - 40,
                                           height: contentView.frame.size.height / 2)
        
        copyButton.frame =          CGRect(x: contentView.frame.size.width - 60,
                                           y: 0,
                                           width: 60,
                                           height: contentView.frame.size.height )
        
        
    }

}
