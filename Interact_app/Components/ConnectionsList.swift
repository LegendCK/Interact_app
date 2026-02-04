//
//  ConnectionsList.swift
//  Interact_app
//
//  Created by admin73 on 22/01/26.
//

import UIKit

class ConnectionsList: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var profileRole: UILabel!
    
   
    @IBOutlet weak var selectButton: UIButton!
    
    // Callback to notify the controller when button is tapped
        var onToggleSelection: (() -> Void)?
        
        override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
        }

        private func setupUI() {
            profileImage.layer.cornerRadius = profileImage.frame.height / 2
            profileImage.contentMode = .scaleAspectFill
            selectButton.layer.cornerRadius = 0
        }

        // MARK: - Configuration
        func configure(with profile: ProfileLite, isSelected: Bool) {
            profileName.text = profile.fullName
            profileRole.text = profile.primaryRole
            
            // Load Image (Add your own image loader here)
            if let urlString = profile.avatarUrl, let url = URL(string: urlString) {
                // self.profileImage.loadImage(from: url)
            } else {
                profileImage.image = UIImage(systemName: "person.circle.fill")
            }
            
            updateButtonState(isSelected: isSelected)
        }
        
        // MARK: - Button Logic
        private func updateButtonState(isSelected: Bool) {
            if isSelected {
                selectButton.setTitle("Selected", for: .normal)
//                selectButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
                selectButton.backgroundColor = .systemGreen
//                selectButton.tintColor = .white
            } else {
                selectButton.setTitle("Select", for: .normal)
                selectButton.setImage(UIImage(systemName: "plus"), for: .normal)
                selectButton.setImage(nil, for: .normal) // Remove icon
                selectButton.backgroundColor = .systemBlue
//                selectButton.tintColor = .white
            }
        }
        
     @IBAction func didTapSelectButton(_ sender: Any) {
            // Trigger the callback. The controller will handle the logic.
            onToggleSelection?()
        }
}
