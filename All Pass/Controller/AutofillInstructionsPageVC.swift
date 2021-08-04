//
//  AutofillInstructionsPageVC.swift
//  All Pass
//
//  Created by Lam Nguyen on 7/9/21.
//

import UIKit

class AutofillInstructionsPageVC: HalfPageModalViewController {
    
    // MARK: asset initialization
    
    let headerLabel: UILabel = {                            //Label to store the header
        let headerLabel = UILabel()
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 30),
                          NSAttributedString.Key.foregroundColor: UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1)]
        headerLabel.attributedText = NSAttributedString(string: "AutoFill", attributes: attributes)
        
        return headerLabel
    }()
    
    let descLabel: UILabel = {
        let descLabel = UILabel()
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                          NSAttributedString.Key.foregroundColor: UIColor(red: 152, green: 152, blue: 152)]
        descLabel.attributedText = NSAttributedString(string: "Follow these instructions to enable AutoFill:", attributes: attributes)
        
        return descLabel
    }()
    
    let table: UITableView = {                              //Table to display the instructions
        let table = UITableView()
        
        return table
    }()
    
    // MARK: view life cycle
    
    override func viewDidLoad() {
        defaultHeight = 410
        currentContainerHeight = 410
        dismissibleHeight = 280
        super.viewDidLoad()
        
        // Set up the header label
        containerView.addSubview(headerLabel)
        
        addLabelConstraints(headerLabel, containerView.topAnchor, 20)
        
        // Set up the description label
        containerView.addSubview(descLabel)
        descLabel.adjustsFontSizeToFitWidth = true
        descLabel.minimumScaleFactor = 0.5
        addLabelConstraints(descLabel, headerLabel.bottomAnchor, 3)
        
        // Set up the table
        containerView.addSubview(table)
        table.delegate = self
        table.dataSource = self
        table.register(AutofillPageTableCell.self, forCellReuseIdentifier: "datacell")
        table.isScrollEnabled = false
        table.separatorStyle = .none
        table.backgroundColor = containerView.backgroundColor
        
        addTableConstraints()
    }
    
    // MARK: asset constraints
    
    func addLabelConstraints(_ label: UILabel, _ topConstraint: NSLayoutYAxisAnchor, _ topConstant: CGFloat){
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: topConstraint, constant: topConstant).isActive = true
        label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12).isActive = true
        label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12).isActive = true
        
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
    }
    
    func addTableConstraints(){
        table.translatesAutoresizingMaskIntoConstraints = false
        table.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 10).isActive = true
        table.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12).isActive = true
        table.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12).isActive = true
        table.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5).isActive = true
    }
    
}

extension AutofillInstructionsPageVC: UITableViewDelegate, UITableViewDataSource{
    
    /*
        @cellForRowAt
        Builds the cell and returns it
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Customize the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "datacell", for: indexPath) as? AutofillPageTableCell
        cell?.backgroundColor = .white
        cell?.selectionStyle = .none
        cell?.switchT.isHidden = true
        
        //Customize the image
        if indexPath.row == 0{
            let image = UIImage(systemName: "gear")
            let iV = UIImageView(image: image)
            iV.frame = CGRect(x: 4, y: 4, width: 34, height: 32)
            iV.backgroundColor = .clear
            iV.contentMode = .scaleAspectFit
            
            cell?.imageV.insertSubview(iV, at: 0)
            cell?.imageV.tintColor = .white
            cell?.imageV.backgroundColor = UIColor(red: 177, green: 177, blue: 177)
            cell?.imageV.layer.cornerRadius = 9
            
            cell?.textL.attributedText = buildText("1. Open Settings")
        }
        else if indexPath.row == 1{
            let image = UIImage(systemName: "key.fill")
            let iV = UIImageView(image: image)
            iV.frame = CGRect(x: 4, y: 4, width: 34, height: 32)
            iV.backgroundColor = .clear
            iV.contentMode = .scaleAspectFit
            
            cell?.imageV.insertSubview(iV, at: 0)
            cell?.imageV.tintColor = .white
            cell?.imageV.backgroundColor = UIColor(red: 177, green: 177, blue: 177)
            cell?.imageV.layer.cornerRadius = 9
            
            cell?.textL.attributedText = buildText("2. Tap on Passwords")
        }
        else if indexPath.row == 2{
            let image = UIImage(systemName: "keyboard")
            cell?.imageV.image = image
            cell?.imageV.contentMode = .scaleAspectFit
            cell?.imageV.tintColor = .white
            cell?.imageV.backgroundColor = .link
            cell?.imageV.layer.cornerRadius = 9
            
            cell?.textL.attributedText = buildText("3. Tap on AutoFill Passwords")
        }
        else if indexPath.row == 3{
            cell?.textL.attributedText = buildText("4. Toggle AutoFill Passwords")
            cell?.switchT.isHidden = false
            cell?.switchT.isOn = true
            cell?.switchT.isEnabled = false
            cell?.switchT.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
        }
        else if indexPath.row == 4{
            let image = UIImage(named: "allpass60x60")
            cell?.imageV.image = image
            cell?.imageV.layer.masksToBounds = true
            cell?.imageV.layer.cornerRadius = 9
            
            cell?.textL.attributedText = buildText("5. Tap to enable All Keys")
        }
        
        return cell!
    }
    
    /*
        @numberOfRowsInSection
        Returns the number of cells
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    /*
        @didSelectRowAt
        Deselects a cell when clicked
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
        @heightForRowAt
        Returns the height of a cell
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func buildText(_ title: String) -> NSAttributedString{
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15),
                          NSAttributedString.Key.foregroundColor: UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1)]
        return NSAttributedString(string: title, attributes: attributes)
    }
}
