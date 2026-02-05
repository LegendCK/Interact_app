//
//  HomeHeaderViewCollectionReusableView.swift
//  Interact_app
//
//  Created by admin56 on 04/02/26.
//

import UIKit

class HomeHeaderViewCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var greetingsLabel: UILabel!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Configure greeting label
        greetingsLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        greetingsLabel.textColor = .label
        
        // Configure notification button (icon already set in XIB)
        notificationButton.tintColor = .systemBlue
        
        // Configure search bar
        searchBar.placeholder = "Search hackathons, teams..."
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
    }
    
    func configure(userName: String) {
        greetingsLabel.text = "Welcome \(userName)!"
    }
}
