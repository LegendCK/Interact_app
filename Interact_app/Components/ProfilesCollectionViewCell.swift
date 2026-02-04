//
//  ProfilesCollectionViewCell.swift
//  Interact_app
//
//  Created by admin73 on 13/01/26.
//

import UIKit

class ProfilesCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var profileRole: UILabel!
    
    @IBOutlet weak var statsLabel: UILabel!
    
    @IBOutlet weak var connectButton: UIButton!
    
    @IBOutlet weak var connectButtonLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    
    // MARK: - Closure
        // This allows the Cell to tell the Controller "I was clicked"
        var onConnectTapped: (() -> Void)?
        
        override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
            
            // Add target for the button click
            connectButton.addTarget(self, action: #selector(didTapConnect), for: .touchUpInside)
        }
        
        // MARK: - Setup
        private func setupUI() {
            // Card Styling
            self.contentView.layer.cornerRadius = 12
//            self.contentView.layer.borderWidth = 1
//            self.contentView.layer.borderColor = UIColor.systemGray5.cgColor
            self.contentView.backgroundColor = .white
            
            // Shadow (Applied to the cell itself, not content view)
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.layer.shadowRadius = 4
            self.layer.shadowOpacity = 0.1
            self.layer.masksToBounds = false
            
            // Image Styling
            if let profileImage = profileImage {
                profileImage.layer.cornerRadius = profileImage.frame.height / 2
                profileImage.contentMode = .scaleAspectFill
                profileImage.clipsToBounds = true
                profileImage.image = UIImage(systemName: "person.circle.fill") // Placeholder
                profileImage.tintColor = .secondaryLabel
            }
            
//            // Button Styling
//            connectButton.layer.cornerRadius = 6
//            connectButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        }
        
        // MARK: - Configuration
        func configure(with model: ProfileDisplayModel) {
            // Name & Role
            profileName.text = model.profile.fullName.isEmpty ? "User" : model.profile.fullName
            profileRole.text = model.profile.primaryRole ?? "Participant"
            
            // Button State Logic
            connectButtonLabel.text = model.buttonTitle
            connectButton.isEnabled = model.isButtonEnabled
            
            if model.isButtonEnabled {
                // "Connect" State
                connectButton.tintColor = .systemBlue
                connectButton.setTitleColor(.white, for: .normal)
            } else {
                // "Pending" or "Connected" State
                connectButton.tintColor = .systemGray5
                connectButton.setTitleColor(.systemGray, for: .disabled)
            }
        }
        
        @objc private func didTapConnect() {
            onConnectTapped?()
        }
        
        // Reset cell when scrolling to avoid bugs
        override func prepareForReuse() {
            super.prepareForReuse()
            onConnectTapped = nil
            profileImage.image = UIImage(systemName: "person.circle.fill")
        }

}
