//
//  PasswordGenTableCell.swift
//  All Pass
//
//  Created by Lam Nguyen on 6/28/21.
//

import UIKit

class PasswordGenTableCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.33
        titleLabel.numberOfLines = 0
        titleLabel.contentMode = .scaleToFill
        
        return titleLabel
    }()
    
    let slider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = 64
        slider.minimumValue = 6
        
        return slider
    }()
    
    let switchToggle: UISwitch = {
       let switchToggle = UISwitch()
        
       return switchToggle
    }()
    
    let copyButton: UIButton = {
        let copyButton = UIButton()
        copyButton.setImage(UIImage(systemName: "doc.on.doc.fill"), for: .normal)
        
        return copyButton
    }()
    
    let sliderValueBackView: UIView = {
        let sliderValueBackView = UIView()
        sliderValueBackView.backgroundColor = UIColor(red: 54/255, green: 145/255, blue: 155/255, alpha: 1)
        sliderValueBackView.layer.cornerRadius = 10
        
        return sliderValueBackView
    }()
    
    let passwordBackView: UIView = {
        let passwordBackView = UIView()
        passwordBackView.backgroundColor = UIColor(red: 54/255, green: 145/255, blue: 155/255, alpha: 1)
        passwordBackView.layer.cornerRadius = 10
        
        return passwordBackView
    }()
    
    let sliderValueLabel: UILabel = {
        let sliderValueLabel = UILabel()
        sliderValueLabel.textAlignment = .center
        sliderValueLabel.textColor = .white
        
        return sliderValueLabel
    }()
    
    let refreshButton: UIButton = {
        let refreshButton = UIButton()
        refreshButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        refreshButton.tintColor = UIColor(red: 213, green: 213, blue: 213)
        return refreshButton
    }()
    
    
    // MARK: initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(red: 62/255, green: 165/255, blue: 176/255, alpha: 1)
        
        //Add the assets to the view
        contentView.addSubview(passwordBackView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(slider)
        contentView.addSubview(switchToggle)
        contentView.addSubview(copyButton)
        sliderValueBackView.addSubview(sliderValueLabel)
        passwordBackView.addSubview(refreshButton)
        contentView.addSubview(sliderValueBackView)
        
        addSliderViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame =          CGRect(x: 18,                                            //Displacement from the left
                                           y: 9,                                             //Displacement from the top
                                           width: contentView.frame.size.width / 1.6,        //Width is size of the cell. CHANGE VALUE IF NEEDED TO CREATE A BORDER FOR THE PASSWORD
                                           height: contentView.frame.size.height / 2)        //Height is half of that of the cell
        
        slider.frame =              CGRect(x: 75,
                                           y: 0,
                                           width: contentView.frame.size.width - 150,
                                           height: contentView.frame.size.height - 8)
        
        
        switchToggle.frame =        CGRect(x: contentView.frame.size.width - 65,
                                           y: 9,
                                           width: 70,
                                           height: contentView.frame.size.height - 8)
        
        passwordBackView.frame =    CGRect(x: 13, y: 1, width: contentView.frame.size.width / 1.34, height: contentView.frame.size.height - 16)
        
        sliderValueBackView.frame = CGRect(x: contentView.frame.size.width - 67,
                                           y: 6,
                                           width: 50,
                                           height: contentView.frame.size.height - 15)
        
        copyButton.frame =          CGRect(x: contentView.frame.size.width - 80,
                                           y: 2,
                                           width: 80,
                                           height: contentView.frame.size.height - 20)
        
        
    }
    
    func addSliderViewConstraints(){
        sliderValueLabel.translatesAutoresizingMaskIntoConstraints = false
        sliderValueLabel.topAnchor.constraint(equalTo: sliderValueBackView.topAnchor, constant: 2).isActive = true
        sliderValueLabel.bottomAnchor.constraint(equalTo: sliderValueBackView.bottomAnchor, constant: -2).isActive = true
        sliderValueLabel.leadingAnchor.constraint(equalTo: sliderValueBackView.leadingAnchor, constant: 1).isActive = true
        sliderValueLabel.trailingAnchor.constraint(equalTo: sliderValueBackView.trailingAnchor, constant: -2).isActive = true
        
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.topAnchor.constraint(equalTo: passwordBackView.topAnchor, constant: 2).isActive = true
        refreshButton.bottomAnchor.constraint(equalTo: passwordBackView.bottomAnchor, constant: -2).isActive = true
        refreshButton.trailingAnchor.constraint(equalTo: passwordBackView.trailingAnchor, constant: -10).isActive = true
    }

    

}
