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
        
        // Give the cell rounded corners
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

            // Add shadow to the outer layer (not clipped by contentView)
        contentView.layer.shadowColor = UIColor.darkGray.withAlphaComponent(0.5).cgColor
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 6)
        contentView.layer.shadowRadius = 8

        
//        contentView.layer.cornerRadius = 10
//        contentView.layer.masksToBounds = true
//        contentView.layer.borderWidth = 1
//        contentView.layer.borderColor = UIColor.lightGray.cgColor

        // Initialization code
    }

}
