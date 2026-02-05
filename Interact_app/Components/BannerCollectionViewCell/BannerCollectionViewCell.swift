//
//  BannerCollectionViewCell.swift
//  Interact_app
//
//  Created by admin56 on 04/02/26.
//

import UIKit

class BannerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var partnerBannerImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Round corners
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        // Configure image view
        partnerBannerImage.contentMode = .scaleAspectFill
        partnerBannerImage.clipsToBounds = true
    }
    
    func configure(imageURL: String?) {
        // Load from Assets (NOT systemName - that's for SF Symbols only!)
        partnerBannerImage.image = UIImage(named: "partnerBanner")
        
        // If image doesn't exist in assets, show placeholder
        if partnerBannerImage.image == nil {
            partnerBannerImage.image = UIImage(systemName: "photo.fill")
            partnerBannerImage.tintColor = .systemGray3
            partnerBannerImage.contentMode = .scaleAspectFit
            partnerBannerImage.backgroundColor = .systemGray6
        }
        
        // Later you'll load from URL using SDWebImage or similar:
        // if let urlString = imageURL, let url = URL(string: urlString) {
        //     partnerBannerImage.sd_setImage(with: url, placeholderImage: UIImage(named: "partnerBanner"))
        // }
    }
}
