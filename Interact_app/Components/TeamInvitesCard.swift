//
//  TeamInvitesCard.swift
//  Interact_app
//
//  Created by admin73 on 23/01/26.
//

import UIKit

class TeamInvitesCard: UICollectionViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var teamLeadName: UILabel!
    
    @IBOutlet weak var teamName: UILabel!
    
    @IBOutlet weak var eventName: UILabel!
    
//    @IBOutlet weak var acceptButton: ButtonComponent!
//    
//    @IBOutlet weak var declineButton: ButtonComponent!
    
    @IBOutlet weak var declineButton: ButtonComponent!
    
    @IBOutlet weak var acceptButton: ButtonComponent!
    
    // MARK: - Properties
        // Closure to pass the decision (true = accept, false = decline) back to the ViewController
        var didTapDecision: ((Bool) -> Void)?
        
        override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
            setupButtons()
        }
        
        // MARK: - UI Setup
        private func setupUI() {
            // Make profile image circular
            profileImage.layer.cornerRadius = profileImage.frame.height / 2
            profileImage.clipsToBounds = true
            profileImage.contentMode = .scaleAspectFill
            
            // Set a default placeholder if no image is available
            profileImage.image = UIImage(systemName: "person.2.circle.fill")
            profileImage.tintColor = .systemGray3
            
            contentView.layer.cornerRadius = 16
            contentView.layer.masksToBounds = true
            
            // Shadow (Applied to the cell itself, not content view)
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 4
            layer.shadowOpacity = 0.1
            layer.masksToBounds = false
        }
        
        // MARK: - Configuration
        func configure(with invite: TeamInviteDisplay) {
            teamName.text = "Team \(invite.teamName) for \(invite.eventName)"
            teamLeadName.text = "\(invite.inviterName) invited you to join"
//            eventName.text = invite.eventName // e.g. "Hackathon 2025"
            
            // Note: If you add an avatar URL to TeamInviteDisplay later, load it here.
        }
        
        func setupButtons() {
            // 1. Configure Accept Button
            acceptButton.configure(
                title: "Accept",
                titleColor: .white,
                backgroundColor: .systemBlue
            )
            
            acceptButton.onTap = { [weak self] in
                // Trigger the closure passing 'true' for Accept
                self?.didTapDecision?(true)
            }
            
            // 2. Configure Decline Button
            declineButton.configure(
                title: "Decline",
                titleColor: .black,
                backgroundColor: .systemGray5
            )
            
            declineButton.onTap = { [weak self] in
                // Trigger the closure passing 'false' for Decline
                self?.didTapDecision?(false)
            }
        }

}
