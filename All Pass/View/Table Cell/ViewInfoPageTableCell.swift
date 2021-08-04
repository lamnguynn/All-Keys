//
//  viewInfoPageTableCell.swift
//  All Pass
//
//  Created by Lam Nguyen on 6/25/21.
//

import UIKit 
import SwiftKeychainWrapper

class viewInfoPageTableCell: UITableViewCell  {
    
    // MARK: asset set up
    let titleLabel: UILabel = {                     //Label to show the title
        let titleLabel = titleLabel()
        titleLabel.contentMode = .bottom
        titleLabel.textColor = UIColor(red: 218/255, green:  218/255, blue:  218/255, alpha: 1)
 
        return titleLabel 
    }()
    
    let infoLabelTF: UITextField = {                  //Label to show the info for the title
        let infoLabelTF = UITextField()
        infoLabelTF.textColor = .white
        infoLabelTF.backgroundColor = .clear
        infoLabelTF.isUserInteractionEnabled = false
        infoLabelTF.adjustsFontForContentSizeCategory = true
        infoLabelTF.minimumFontSize = 8
        
        return infoLabelTF
    }()
    
    let eyeButton: UIButton = {                     //Button to show the password
        let eyeButton = UIButton()
        eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        
        return eyeButton
    }()
    
    let copyButton: UIButton = {
        let copyButton = UIButton()
        copyButton.setImage(UIImage(systemName: "doc.on.doc.fill"), for: .normal)
        
        return copyButton
    }()
    
    
    var numberEyesClicked: Int = 0                  //Number of times the eye button is clicked. Used to toggle the image
    var key: String?                                //Key to use in keychain
    var parentVC: ViewInfoPageVC!
    
    // MARK: initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(red: 62/255, green: 165/255, blue: 176/255, alpha: 1)
        //Add the assets to the view
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoLabelTF)
        contentView.addSubview(eyeButton)
        contentView.addSubview(copyButton)
        
        
        //Show the password when the eye is clicked
        eyeButton.addTarget(self, action: #selector(showPassword), for: .touchUpInside)
        
        //Copy the text to clipboard when copy button is clicks
        copyButton.addTarget(self, action: #selector(copyToBoard), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = CGRect(x: 12,                                            //Displacement from the left
                                  y: 0,                                             //Displacement from the top
                                  width: contentView.frame.size.width - 40,         //Width is size of the cell
                                  height: contentView.frame.size.height / 2)        //Height is half of that of the cell
        
        let yPadding = self.contentView.frame.size.height / 11.4829929897
        infoLabelTF.frame = CGRect(x: 12, y: self.contentView.frame.size.height / 2 - yPadding,
                                 width: contentView.frame.size.width - 40,
                                 height: contentView.frame.size.height / 2)
        
        eyeButton.frame = CGRect(x: contentView.frame.size.width - 110,
                                 y: self.contentView.frame.size.height / 2,
                                 width: 60,
                                 height: contentView.frame.size.height / 4.3)
        
        copyButton.frame = CGRect(x: contentView.frame.size.width - 65,
                                  y: self.contentView.frame.size.height / 2,
                                  width: 60,
                                  height: contentView.frame.size.height / 4.3)
        
    }
    
    @objc func showPassword(){
        //If the number of clicks is even, then show the password
        if numberEyesClicked % 2 == 0{
            //Show
            DispatchQueue.main.async {
                self.eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
                self.infoLabelTF.text = KeychainWrapper.standard.string(forKey: self.key!)
            }
        }
        else{
            //Hide
            DispatchQueue.main.async{
                self.eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
                let censor = String(repeating: "*", count: KeychainWrapper.standard.string(forKey: self.key!)!.count)
                self.infoLabelTF.text = censor
            }
        }
        
        //Update the number of times clicked
        numberEyesClicked += 1
    }
    
    @objc func copyToBoard(){
        //Show an alert for 1 seconds
        let alertController = UIAlertController(title: "Copied!", message: nil, preferredStyle: .alert)
        parentVC.present(alertController, animated: true)
        
        //Using GCD as my timer. Quite overkill as nothing is happening on the main thread.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.86) {
            self.parentVC.dismiss(animated: true, completion: nil)
        }
        
        if self.titleLabel.text == "Username"{
            UIPasteboard.general.string = self.infoLabelTF.text
            
        }
        else{
            UIPasteboard.general.string = KeychainWrapper.standard.string(forKey: self.key!)
        }
    }
}

//Subclass UILabel in order to create a custom label that will allow vertical alignment
class titleLabel: UILabel{
    override func drawText(in rect: CGRect) {
        var newRect = rect
        
        switch contentMode {
                case .bottom:
                    let height = sizeThatFits(rect.size).height
                    newRect.origin.y += rect.size.height - height - 7
                    newRect.size.height = height
                    
                default:
                    ()
        }
                
        super.drawText(in: newRect)
    }
}
