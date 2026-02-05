//
//  ParticipantCardCell.swift
//  Interact-UIKit
//
//  Created by admin73 on 17/11/25.
//

import UIKit

class ParticipantCardCell: UICollectionViewCell {
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var teamLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var registrationDateLabel: UILabel!
    
    override func awakeFromNib() {
            super.awakeFromNib()
            setupCardAppearance()
        }
        
    func configure(
        name: String,
        teamName: String?,
        email: String?,
        joinedAt: Date
    ) {
        nameLabel.text = name
        teamLabel.text = teamName ?? "No Team"
        emailLabel.text = email ?? "No Email"

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        registrationDateLabel.text = "Registered: \(formatter.string(from: joinedAt))"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        teamLabel.text = nil
        emailLabel.text = nil
        registrationDateLabel.text = nil
    }

        
        private func setupCardAppearance() {
            cardView.layer.cornerRadius = 12
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
            cardView.layer.shadowRadius = 4
            cardView.layer.shadowOpacity = 0.1
            cardView.backgroundColor = .systemBackground
            
            // Style labels
            nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            teamLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            teamLabel.textColor = .systemBlue
            emailLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            emailLabel.textColor = .darkGray
            registrationDateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            registrationDateLabel.textColor = .systemGray
        }

}
