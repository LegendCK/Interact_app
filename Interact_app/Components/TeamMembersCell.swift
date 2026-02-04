//
//  TeamMembersCell.swift
//  Interact_app
//
//  Created by admin73 on 26/01/26.
//

import UIKit

class TeamMembersCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var teamMemberName: UILabel!
    
    @IBOutlet weak var teamMemberTechnicalRole: UILabel!
    
    @IBOutlet weak var teamLeaderOrMemberButton: UIButton!
    
    
    // MARK: - Lifecycle
        override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        }
        
        // MARK: - Setup UI
        private func setupUI() {
            // Round Image
            profileImage.layer.cornerRadius = profileImage.frame.height / 2
            profileImage.clipsToBounds = true
            profileImage.contentMode = .scaleAspectFill
            profileImage.layer.borderWidth = 1
            profileImage.layer.borderColor = UIColor.systemGray5.cgColor
            
            // Style the Badge (Button)
            teamLeaderOrMemberButton.isUserInteractionEnabled = false // Make it read-only
            teamLeaderOrMemberButton.layer.cornerRadius = 0
            teamLeaderOrMemberButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
            teamLeaderOrMemberButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        }
        
        // MARK: - Configuration
        func configure(with member: TeamMemberDisplay) {
            // 1. Set Name
            teamMemberName.text = member.fullName
            
            // 2. Set Technical Role (or fallback)
            teamMemberTechnicalRole.text = member.technicalRole ?? "Member"
            
            // 3. Set Leader/Member Status Badge
            if member.role == "leader" {
                styleBadge(title: "Leader", color: .black)
            } else {
                styleBadge(title: "Member", color: .black)
            }
            
            // 4. Load Image (Basic placeholder logic)
            // Note: The actual image downloading is best done in the ViewController or using a library like Kingfisher
            profileImage.image = UIImage(systemName: "person.circle.fill")
            profileImage.tintColor = .systemGray4
            
            if let urlString = member.avatarUrl, let url = URL(string: urlString) {
                // Simple async load (Ideally use SDWebImage/Kingfisher in production)
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.profileImage.image = image
                        }
                    }
                }
            }
        }
        
        private func styleBadge(title: String, color: UIColor) {
            teamLeaderOrMemberButton.setTitle(title, for: .normal)
            teamLeaderOrMemberButton.setTitleColor(color, for: .normal)
            teamLeaderOrMemberButton.backgroundColor = color.withAlphaComponent(0.1) // Light pastel background
            teamLeaderOrMemberButton.layer.borderColor = color.withAlphaComponent(0.3).cgColor
            teamLeaderOrMemberButton.layer.borderWidth = 1
        }
}
