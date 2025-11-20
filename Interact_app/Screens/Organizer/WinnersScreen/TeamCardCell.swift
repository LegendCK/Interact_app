//
//  TeamCardCell.swift
//  Interact_app
//
//  Created by admin73 on 20/11/25.
//

import UIKit

import UIKit

class TeamCardCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var teamNameLabel: UILabel!
    
    @IBOutlet weak var teamLeaderLabel: UILabel!
    
    @IBOutlet weak var memberCountLabel: UILabel!
    
    @IBOutlet weak var prizeBadgeContainer: UIView!
    
    @IBOutlet weak var prizeBadgeLabel: UILabel!
    
    // MARK: - Properties
    private let goldColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
    private let silverColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
    private let bronzeColor = UIColor(red: 0.80, green: 0.50, blue: 0.20, alpha: 1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellAppearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetAppearance()
    }
    
    private func setupCellAppearance() {
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 3
        containerView.layer.borderColor = UIColor.clear.cgColor
        containerView.layer.masksToBounds = true
        
        prizeBadgeContainer.layer.cornerRadius = 8
        prizeBadgeContainer.isHidden = true
        
        // Add shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false
    }
    
    private func resetAppearance() {
        containerView.backgroundColor = .systemBackground
        containerView.layer.borderColor = UIColor.clear.cgColor
        prizeBadgeContainer.isHidden = true
    }
    
    func configure(with team: Team, prizeRank: Int) {
        teamNameLabel.text = team.teamName ?? "Unknown Team"
        teamLeaderLabel.text = "Lead: \(team.teamLeader ?? "Unknown Leader")" 
        memberCountLabel.text = "\(team.memberCount) members"
        
        updateAppearance(for: prizeRank)
    }
    
    private func updateAppearance(for prizeRank: Int) {
        switch prizeRank {
        case 1:
            // First Prize - Gold
            containerView.backgroundColor = goldColor.withAlphaComponent(0.2)
            containerView.layer.borderColor = goldColor.cgColor
            prizeBadgeLabel.text = "First Prize"
            prizeBadgeContainer.backgroundColor = goldColor
            prizeBadgeContainer.isHidden = false
            
        case 2:
            // Second Prize - Silver
            containerView.backgroundColor = silverColor.withAlphaComponent(0.2)
            containerView.layer.borderColor = silverColor.cgColor
            prizeBadgeLabel.text = "Second Prize"
            prizeBadgeContainer.backgroundColor = silverColor
            prizeBadgeContainer.isHidden = false
            
        case 3:
            // Third Prize - Bronze
            containerView.backgroundColor = bronzeColor.withAlphaComponent(0.2)
            containerView.layer.borderColor = bronzeColor.cgColor
            prizeBadgeLabel.text = "Third Prize"
            prizeBadgeContainer.backgroundColor = bronzeColor
            prizeBadgeContainer.isHidden = false
            
        default:
            // No prize - Default appearance
            containerView.backgroundColor = .systemBackground
            containerView.layer.borderColor = UIColor.systemGray5.cgColor
            containerView.layer.borderWidth = 1
            prizeBadgeContainer.isHidden = true
        }
        
        // Add animation for selection
//        if prizeRank > 0 {
//            animateSelection()
//        }
    }
    
    private func animateSelection() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
    }
}
