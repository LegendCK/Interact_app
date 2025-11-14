//
//  ProfileScreenViewController.swift
//  Interact-UIKit
//
//  Created by admin73 on 08/11/25.
//

import UIKit

class ProfileScreenViewController: UIViewController {

    private let label: UILabel = {
        let label = UILabel()
        label.text = "Profile screen is coming soon"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = .systemBackground
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
