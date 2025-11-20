//
//  RSVPCell.swift
//  Interact-UIKit
//
//  Created by admin73 on 18/11/25.
//

import UIKit

class RSVPCell: UICollectionViewCell {
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var teamLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var attendanceLabel: UILabel!
    
    @IBOutlet weak var attendanceButton: UIButton!
    
    @IBOutlet weak var foodLabel: UILabel!
    
    @IBOutlet weak var foodButton: UIButton!
    
    @IBOutlet weak var checkedInAt: UILabel!
    
    @IBOutlet weak var foodStackView: UIStackView!
    
    
    // MARK: - Properties
    var onAttendanceTapped: ((Bool) -> Void)?
    var onFoodTapped: ((Bool) -> Void)?
    
    private var participant: Participant?
    private var isAttended: Bool = false
    private var hasFood: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardAppearance()
        setupButtons()
    }
    
    func configure(with participant: Participant, rsvpForFood: Bool) {
        self.participant = participant
        self.isAttended = participant.isAttended
        self.hasFood = participant.hasFood
        
        nameLabel.text = participant.name ?? "Unknown"
        teamLabel.text = participant.teamName ?? "No Team"
        emailLabel.text = participant.email ?? "No Email"

        // Format the date properly
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current
            
        if let checkedInDate = participant.checkedInAt {
            checkedInAt.text = "Checked in at: \(dateFormatter.string(from: checkedInDate))"
        } else {
            checkedInAt.text = "Not checked in yet"
        }
        
        foodStackView.isHidden = !rsvpForFood
        updateButtonAppearance()
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
        
        attendanceLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        foodLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        checkedInAt.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    }
    
    private func setupButtons() {
        // Attendance button
        attendanceButton.addTarget(self, action: #selector(attendanceTapped), for: .touchUpInside)
        
        // Food button
        foodButton.addTarget(self, action: #selector(foodTapped), for: .touchUpInside)
        
        updateButtonAppearance()
    }
    
    private func updateButtonAppearance() {
        // Update attendance button
        if isAttended {
            attendanceButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            attendanceButton.tintColor = .systemGreen
            attendanceLabel.textColor = .systemGreen
        } else {
            attendanceButton.setImage(UIImage(systemName: "square"), for: .normal)
            attendanceButton.tintColor = .systemGray
            attendanceLabel.textColor = .label
        }
        
        // Update food button
        if hasFood {
            foodButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            foodButton.tintColor = .systemOrange
            foodLabel.textColor = .systemOrange
        } else {
            foodButton.setImage(UIImage(systemName: "square"), for: .normal)
            foodButton.tintColor = .systemGray
            foodLabel.textColor = .label
        }
    }
    
    @objc private func attendanceTapped() {
        isAttended.toggle()
        updateButtonAppearance()
        updateCheckInText()
        onAttendanceTapped?(isAttended)
    }
    
    @objc private func foodTapped() {
        hasFood.toggle()
        updateButtonAppearance()
        onFoodTapped?(hasFood)
    }
    
    private func updateCheckInText() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        if isAttended {
            let checkInDate = participant?.checkedInAt ?? Date()
            checkedInAt.text = "Checked in at: \(dateFormatter.string(from: checkInDate))"
        } else {
            checkedInAt.text = "Not checked in"
        }
    }
}
