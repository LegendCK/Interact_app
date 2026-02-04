//
//  ConnectionInvitesCard.swift
//  Interact_app
//
//  Created by admin73 on 18/01/26.
//

import UIKit

class ConnectionInvitesCard: UICollectionViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var declineButton: ButtonComponent!
    @IBOutlet weak var acceptButton: ButtonComponent!
    
    // MARK: - Properties
        // Callback: (True = Accept, False = Decline)
        var didTapDecision: ((Bool) -> Void)?
        
        override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
            setupButtons()
        }
        
        // MARK: - Setup
        private func setupUI() {
            // Optional: Make image circular if you haven't done so in Storyboard
            profileImage.layer.cornerRadius = profileImage.frame.height / 2
            profileImage.clipsToBounds = true
            profileImage.contentMode = .scaleAspectFill
            
            contentView.layer.cornerRadius = 16
            contentView.layer.masksToBounds = true
            
            // Shadow (Applied to the cell itself, not content view)
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 4
            layer.shadowOpacity = 0.1
            layer.masksToBounds = false
        }
        
        func setupButtons() {
            // Configure Accept Button
            acceptButton.configure(
                title: "Accept",
                titleColor: .white,
                backgroundColor: .systemBlue
            )
            
            acceptButton.onTap = { [weak self] in
                // Send 'true' to the controller
                self?.didTapDecision?(true)
            }
            
            // Configure Decline Button
            declineButton.configure(
                title: "Decline",
                titleColor: .black,
                backgroundColor: .systemGray5 // 'lightGray' can sometimes be too dark for black text
            )
            
            declineButton.onTap = { [weak self] in
                // Send 'false' to the controller
                self?.didTapDecision?(false)
            }
        }
        
        // MARK: - Configuration
        func configure(with request: ConnectionRequest) {
            // 1. Set Name
            profileName.text = request.sender.fullName
            
            // 2. Set Image
            // If you are using a URL, load it here.
            // For now, we use a placeholder or the first letter of their name.
            profileImage.image = UIImage(systemName: "person.circle.fill")
            
            // Optional: If request.sender has an avatarURL string, use SDWebImage or Kingfisher here
            // if let urlString = request.sender.avatarUrl, let url = URL(string: urlString) { ... }
        }

}
