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
//        eventImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        eventImageView.clipsToBounds = true
//
//        contentView.layer.cornerRadius = 12
//        contentView.layer.masksToBounds = true
//        contentView.layer.shadowColor = UIColor.darkGray.withAlphaComponent(0.5).cgColor
//        contentView.layer.shadowOpacity = 1
//        contentView.layer.shadowOffset = CGSize(width: 0, height: 6)
//        contentView.layer.shadowRadius = 8

        // Initialization code
        setupUI()
    }
    
    private func setupUI() {
        // Add card-like appearance
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray5.cgColor
        
        // Add shadow for depth
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false
    
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        
    }

}
