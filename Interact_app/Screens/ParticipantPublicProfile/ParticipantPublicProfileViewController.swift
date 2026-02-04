//
//  ParticipantPublicProfileViewController.swift
//  Interact_app
//
//  Created by admin56 on 17/01/26.
//

import UIKit

class PublicProfileViewController: UIViewController {

    var qrToken: String!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var skillsLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        loadProfile()
    }

    private func loadProfile() {
        guard
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
            let auth = sceneDelegate.authManager
        else { return }

        auth.fetchPublicProfile(qrToken: qrToken) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    guard let profile else { return }

                    let first = profile["first_name"] as? String ?? ""
                    let last  = profile["last_name"] as? String ?? ""
                    self?.nameLabel.text = "\(first) \(last)"

                    self?.bioLabel.text = profile["bio"] as? String ?? "—"

                    let skills = profile["skills"] as? [String] ?? []
                    self?.skillsLabel.text = skills.joined(separator: ", ")

                case .failure(let error):
                    print("Public profile error:", error.localizedDescription)
                }
            }
        }
    }
}

