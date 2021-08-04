//
//  HomePageTableCell.swift
//  All Pass
//
//  Created by Lam Nguyen on 6/18/21.
//

import UIKit

protocol copyPasswordDelegate: AnyObject {
    func copyPass(cell: HomePageTableCell)
}

class HomePageTableCell: UITableViewCell {
    var delegate: copyPasswordDelegate?
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var copyButton: UIButton!
    @IBOutlet var cellBackView: UIView!
    @IBOutlet var companyBackView: UIView!
    @IBOutlet var companyInterBackView: UIView!
    @IBOutlet var companyInitialLabel: UILabel!
    
    @IBAction func copyClicked(_ sender: UIButton){
        delegate?.copyPass(cell: self)
    }
    
}
