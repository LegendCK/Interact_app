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
    
    @IBOutlet weak var checkedInAtLabel: UILabel!
    
    
    @IBOutlet weak var foodStackView: UIStackView!
    
    
    // MARK: - Properties
    var onAttendanceTapped: ((Bool) -> Void)?
    var onFoodTapped: ((Bool) -> Void)?
    
    private var isAttended: Bool = false
    private var hasFood: Bool = false
    private var checkedInDate: Date?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardAppearance()
        setupButtons()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isAttended = false
        hasFood = false
        checkedInDate = nil
    }

    func configure(
        name: String,
        teamName: String?,
        email: String?,
        isAttended: Bool,
        hasFood: Bool,
        checkedInAt: Date?,
        rsvpForFood: Bool
    ) {
        self.isAttended = isAttended
        self.hasFood = hasFood
        self.checkedInDate = checkedInAt

        nameLabel.text = name
        teamLabel.text = teamName ?? "No Team"
        emailLabel.text = email ?? "No Email"

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        if let checkInDate = checkedInAt {
            checkedInAtLabel.text = "Checked in at: \(formatter.string(from: checkInDate))"
        } else {
            checkedInAtLabel.text = "Not checked in yet"
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
        checkedInAtLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
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
            attendanceButton.tintColor = .systemBlue
            attendanceLabel.textColor = .systemBlue
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
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        if isAttended {
            let date = checkedInDate ?? Date()
            checkedInAtLabel.text = "Checked in at: \(formatter.string(from: date))"
            checkedInDate = date
        } else {
            checkedInAtLabel.text = "Not checked in"
            checkedInDate = nil
        }
    }

}
