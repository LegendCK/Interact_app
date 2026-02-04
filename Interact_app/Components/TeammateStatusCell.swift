//
//  TeammateStatusCell.swift
//  Interact_app
//
//  Created by admin73 on 23/01/26.
//

import UIKit

class TeammateStatusCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var profileRole: UILabel!
    
    @IBOutlet weak var profileStatus: UIButton!
    
    override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
        }

        private func setupUI() {
            // Make image circular
            profileImage.layer.cornerRadius = profileImage.frame.height / 2
            profileImage.clipsToBounds = true
            profileImage.contentMode = .scaleAspectFill
            
            // Style the status button (Capsule shape)
//            profileStatus.layer.cornerRadius = 12
            profileStatus.isUserInteractionEnabled = false // Make it just a label looking like a button
        }

        func configure(with member: TeamMemberDisplay) {
            profileName.text = member.fullName
            profileRole.text = member.role?.capitalized ?? "Member"
            
            // Handle Avatar
            if let urlString = member.avatarUrl, let url = URL(string: urlString) {
                // Load image asynchronously (Use a library like Kingfisher or SDWebImage if you have it)
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            self.profileImage.image = UIImage(data: data)
                        }
                    }
                }
            } else {
                profileImage.image = UIImage(systemName: "person.circle.fill") // Placeholder
                profileImage.tintColor = .gray
            }
            
            // Handle Status Button Appearance
            if member.status == "accepted" {
                profileStatus.setTitle("Accepted", for: .normal)
                profileStatus.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
                profileStatus.setTitleColor(.systemGreen, for: .normal)
            } else {
                profileStatus.setTitle("Pending", for: .normal)
                profileStatus.backgroundColor = UIColor.systemGray.withAlphaComponent(0.2)
                profileStatus.setTitleColor(.black, for: .normal)
            }
        }
    
}
