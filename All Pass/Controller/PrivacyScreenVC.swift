//
//  PrivacyScreeenVC.swift
//  TestingBio
//
//  Created by Lam Nguyen on 6/18/21.
//

import Foundation
import UIKit

class PrivacyScreenVC: UITableViewController{
    init() {
        super.init(style: .grouped)
        
        //Change the background color
        view.backgroundColor = UIColor(red: 7/255, green: 82/255, blue: 85/255, alpha: 1)
        
        //Add logo to the privacy screen
        let logoImage = UIImage(named: "allpass152x152")
        let imageView = UIImageView(image: logoImage)
        
        view.addSubview(imageView)
        
        //Apply constraints to the image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.main.bounds.size.height / 5.6).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.backgroundColor = .clear
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
