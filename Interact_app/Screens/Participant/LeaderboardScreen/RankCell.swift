//
//  RankCell.swift
//  Interact_app
//
//  Created by admin73 on 14/12/25.
//

import UIKit

class RankCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var rankNumber: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var numberOfWins: UILabel!
    
    @IBOutlet weak var numberOfParticipations: UILabel!
    
    @IBOutlet weak var totalPoints: UILabel!
    
    // MARK: - Lifecycle
        override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            profileImage.image = UIImage(named: "ProfileImage")
        }
        
        // MARK: - UI Setup
        private func setupUI() {
            // Container styling
            containerView.layer.cornerRadius = 16
            containerView.layer.masksToBounds = false
//            containerView.backgroundColor = .secondarySystemBackground
//            
//            containerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
//            containerView.layer.shadowOpacity = 1
//            containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
//            containerView.layer.shadowRadius = 6
//            
//            // Profile Image styling
//            profileImage.layer.cornerRadius = profileImage.frame.height / 2
//            profileImage.clipsToBounds = true
//            profileImage.contentMode = .scaleAspectFill
//            
//            // Text styles (optional but recommended)
//            rankNumber.font = .preferredFont(forTextStyle: .headline)
//            nameLabel.font = .preferredFont(forTextStyle: .body)
//            numberOfWins.font = .preferredFont(forTextStyle: .caption1)
//            numberOfParticipations.font = .preferredFont(forTextStyle: .caption1)
//            totalPoints.font = .preferredFont(forTextStyle: .headline)
        }
        
        // MARK: - Configuration
        func configure(
            rank: Int,
            name: String,
            wins: Int,
            participations: Int,
            points: Int,
            image: UIImage? = nil
        ) {
            rankNumber.text = "\(rank)"
            nameLabel.text = name
            numberOfWins.text = "\(wins)"
            numberOfParticipations.text = "\(participations)"
            totalPoints.text = "\(points)"
            
            profileImage.image = image ?? UIImage(named: "placeholder_profile")
        }

}
