//
//  AutofillPageTableCell.swift
//  All Pass
//
//  Created by Lam Nguyen on 7/9/21.
//

import UIKit

class AutofillPageTableCell: UITableViewCell {
    
    let imageV = UIImageView()
    let textL = UILabel()
    let switchT = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //Add the assets to the view
        contentView.addSubview(imageV)
        contentView.addSubview(textL)
        contentView.addSubview(switchT)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageV.frame =          CGRect(x: 0,                                                        //Displacement from the left
                                       y: 10,                                                       //Displacement from the top
                                       width: 42,                                                   //Width is size of the cell
                                       height: contentView.frame.size.height - 18)                  //Height is half of that of the cell
        
        textL.frame  =          CGRect(x: 50,
                                       y: 10,
                                       width: contentView.frame.size.width - 62,
                                       height: contentView.frame.size.height - 20)
        
        switchT.frame =         CGRect(x: 0,
                                       y: 16,
                                       width: 42,
                                       height: contentView.frame.size.height - 20)
    }

}
