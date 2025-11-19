//
//  ParticipantProfileSetupViewController.swift
//  Interact_app
//
//  Created by admin56 on 17/11/25.
//
//
//  ParticipantProfileSetupViewController.swift
//  Interact_app
//

import UIKit

class ParticipantProfileSetupViewController: UIViewController {

    // Passed from VerifyAccountViewController
    var userRole: UserRole?

    @IBOutlet weak var saveButton: ButtonComponent!

    override func viewDidLoad() {
        super.viewDidLoad()

        saveButton.configure(title: "Save & Continue")
        saveButton.onTap = { [weak self] in
            self?.completeSetup()
        }
    }

    private func completeSetup() {
        guard let role = userRole else { return }

        // Save role permanently
        UserDefaults.standard.set(role.rawValue, forKey: "UserRole")

        // Route based on role
        let homeVC: UIViewController =
            (role == .organizer)
            ? MainTabBarController()
            : ParticipantMainTabBarController()

        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(homeVC)
        }
    }
}

