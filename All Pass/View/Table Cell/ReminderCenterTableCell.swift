//
//  NotificationCenterTableCell.swift
//  All Pass
//
//  Created by Lam Nguyen on 7/5/21.
//

import UIKit

protocol MoreInfoDelegate: AnyObject {
    func moreClicked(cell: ReminderCenterTableCell)
}

class ReminderCenterTableCell: UITableViewCell {

    // MARK: asset set up
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        
        return titleLabel
    }()
    
    let infoLabel: UILabel = {
       let infoLabel = UILabel()
        
        return infoLabel
    }()
    
    let moreInfoButton: UIButton = {
        let moreInfoButton = UIButton()
        moreInfoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
        moreInfoButton.tintColor = UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1)
        return moreInfoButton
    }()
    
    weak var delegate: MoreInfoDelegate?
    
    // MARK: initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(moreInfoButton)
        
        moreInfoButton.addTarget(self, action: #selector(moreInfoClicked), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame =          CGRect(x: 12,                                            //Displacement from the left
                                           y: 0,                                             //Displacement from the top
                                           width: contentView.frame.size.width - 40,         //Width is size of the cell
                                           height: contentView.frame.size.height / 2)        //Height is half of that of the cell
        
        infoLabel.frame =           CGRect(x: 12,
                                           y: contentView.frame.size.height / 2 - 8,
                                           width: contentView.frame.size.width - 40,
                                           height: contentView.frame.size.height / 2)
        
        moreInfoButton.frame =      CGRect(x: contentView.frame.size.width - 65,
                                           y: 0,
                                           width: 90,
                                           height: contentView.frame.size.height)
    }
    
    @objc func moreInfoClicked(){
        delegate?.moreClicked(cell: self)
    }

}
