//
//  RoleCollectionViewCell.swift
//  Interact_app
//
//  Created by admin56 on 04/02/26.
//

import UIKit

class RoleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Make the container circular
        iconContainerView.layer.cornerRadius = 30 // Half of 60 (width/height)
        iconContainerView.clipsToBounds = true
        iconContainerView.backgroundColor = .systemGray6
        
        // Configure icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue
        
        // Configure title label
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
    }
    
    func configure(iconName: String, title: String) {
        iconImageView.image = UIImage(systemName: iconName)
        titleLabel.text = title
    }
}
