//
//  NewCredentialCollectionCell.swift
//  All Keys
//
//  Created by Lam Nguyen on 7/21/21.
//

import UIKit

final class NewCredentialCollectionCell: UICollectionViewCell {
    var categoryLabel: UILabel = {
        let categoryLabel = UILabel()
        categoryLabel.textColor = .white
        
        return categoryLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(categoryLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        categoryLabel.frame = CGRect(x: 10, y: 2, width: self.contentView.frame.width, height: self.contentView.frame.height - 5)
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layoutIfNeeded()
    }
}
