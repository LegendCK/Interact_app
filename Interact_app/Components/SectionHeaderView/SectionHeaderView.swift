//
//  SectionHeaderView.swift
//  Interact_app
//
//  Created by admin56 on 04/02/26.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    
    // Callback for See All button tap
    var seeAllAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Configure title label (text style already set in XIB)
        titleLabel.textColor = .label
        
        // Configure See All button
        seeAllButton.setTitleColor(.systemBlue, for: .normal)
        seeAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        seeAllButton.addTarget(self, action: #selector(seeAllTapped), for: .touchUpInside)
    }
    
    func configure(title: String, showSeeAll: Bool = true) {
        titleLabel.text = title
        seeAllButton.isHidden = !showSeeAll
    }
    
    @objc private func seeAllTapped() {
        seeAllAction?()
    }
}
