//
//  EventCardCell.swift
//  Interact-UIKit
//
//  Created by admin73 on 06/11/25.
//

import UIKit

class EventCardCell: UICollectionViewCell {
    
    
    @IBOutlet weak var eventImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var venueLabel: UILabel!
    
    @IBOutlet weak var shareButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        eventImageView.layer.cornerRadius = 8
        eventImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        eventImageView.clipsToBounds = true

        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.layer.shadowColor = UIColor.darkGray.withAlphaComponent(0.5).cgColor
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 6)
        contentView.layer.shadowRadius = 8

        // Initialization code
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        
    }
    
    
    // Add to EventCardCell class
//    func configureStatusBadge(text: String, color: UIColor) {
//        // Remove existing status badge if any
//        viewWithTag(999)?.removeFromSuperview()
//        
//        let badge = UILabel()
//        badge.tag = 999
//        badge.text = text
//        badge.textColor = .white
//        badge.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
//        badge.backgroundColor = color
//        badge.textAlignment = .center
//        badge.layer.cornerRadius = 5
//        badge.clipsToBounds = true
//        
//        badge.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(badge)
//        
//        NSLayoutConstraint.activate([
//            badge.topAnchor.constraint(equalTo: eventImageView.topAnchor, constant: 8),
//            badge.trailingAnchor.constraint(equalTo: eventImageView.trailingAnchor, constant: -8),
//            badge.heightAnchor.constraint(equalToConstant: 25),
//            badge.widthAnchor.constraint(equalToConstant: 120)
//        ])
//    }

}
