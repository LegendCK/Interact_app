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
        eventImageView.layer.cornerRadius = 12
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
