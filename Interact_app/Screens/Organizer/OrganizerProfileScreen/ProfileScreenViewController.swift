//
//  ProfileScreenViewController.swift
//  Interact-UIKit
//
//  Created by admin73 on 08/11/25.
//

import UIKit

class ProfileScreenViewController: UIViewController {

    @IBOutlet weak var orgProfileImage: UIImageView!
    @IBOutlet weak var organizationName: UILabel!
    @IBOutlet weak var userIdAndRole: UILabel!
    @IBOutlet weak var organizationEmailAddress: UILabel!
    @IBOutlet weak var editProfileButton: ButtonComponent!
    @IBOutlet weak var viewAllRecentEventsButton: UIButton!

    @IBOutlet weak var aboutViewContainer: UIView!
    @IBOutlet weak var recentEventViewContainer: UIView!

    @IBOutlet weak var recentEvent1Image: UIImageView!
    @IBOutlet weak var recentEvent1Title: UILabel!
    @IBOutlet weak var recentEvent1Date: UILabel!
    @IBOutlet weak var recentEvent1TotalRegLabel: UIView!

    @IBOutlet weak var recentEvent2Image: UIImageView!
    @IBOutlet weak var recentEvent2Title: UILabel!
    @IBOutlet weak var recentEvent2Date: UILabel!
    @IBOutlet weak var recentEvent2TotalRegLabel: UIView!

    @IBOutlet weak var recentEvent3Image: UIImageView!
    @IBOutlet weak var recentEvent3Title: UILabel!
    @IBOutlet weak var recentEvent3Date: UILabel!
    @IBOutlet weak var recentEvent3TotalRegLabel: UIView!

    @IBOutlet weak var moreOptionMenuButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMenu()
    }
}

// MARK: - UI SETUP

extension ProfileScreenViewController {

    private func setupUI() {
        aboutViewContainer.layer.borderWidth = 1
        aboutViewContainer.layer.cornerRadius = 10
        aboutViewContainer.layer.borderColor = UIColor.systemGray4.cgColor

        recentEventViewContainer.layer.borderWidth = 1
        recentEventViewContainer.layer.cornerRadius = 10
        recentEventViewContainer.layer.borderColor = UIColor.systemGray4.cgColor

        recentEvent1TotalRegLabel.backgroundColor = .systemBlue
        recentEvent1TotalRegLabel.layer.cornerRadius = 6

        recentEvent2TotalRegLabel.backgroundColor = .systemBlue
        recentEvent2TotalRegLabel.layer.cornerRadius = 6

        recentEvent3TotalRegLabel.backgroundColor = .systemBlue
        recentEvent3TotalRegLabel.layer.cornerRadius = 6

        editProfileButton.configure(title: "Edit profile")

        moreOptionMenuButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        moreOptionMenuButton.tintColor = .label
    }
}

// MARK: - MENU SETUP

extension ProfileScreenViewController {

    private func setupMenu() {

        moreOptionMenuButton.changesSelectionAsPrimaryAction = false
        moreOptionMenuButton.isSelected = false

        let changePassword = UIAction(
            title: "Change Password",
            image: UIImage(systemName: "key"),
            state: .off
        ) { _ in
            self.handleChangePassword()
        }

        let termsService = UIAction(
            title: "Terms & Services",
            image: UIImage(systemName: "doc.text"),
            state: .off
        ) { _ in
            self.handleTerms()
        }

        let requestDeletion = UIAction(
            title: "Request Account Deletion",
            image: UIImage(systemName: "trash"),
            state: .off
        ) { _ in
            self.handleAccountDeletion()
        }

        let helpSupport = UIAction(
            title: "Help & Support",
            image: UIImage(systemName: "questionmark.circle"),
            state: .off
        ) { _ in
            self.handleHelpSupport()
        }

        let logout = UIAction(
            title: "Logout",
            image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
            attributes: .destructive,
            state: .off
        ) { _ in
            self.confirmLogout()
        }

        moreOptionMenuButton.menu = UIMenu(
            title: "",
            options: [.displayInline, .destructive],
            children: [
                changePassword,
                termsService,
                requestDeletion,
                helpSupport,
                logout
            ]
        )

        moreOptionMenuButton.showsMenuAsPrimaryAction = true
    }

}

// MARK: - MENU ACTION HANDLING

extension ProfileScreenViewController {

    func handleChangePassword() {
        print("Change Password tapped")
        // Navigate to Change Password screen
    }

    func handleTerms() {
        print("Terms & Services tapped")
        // Present Terms / WebView
    }

    func handleAccountDeletion() {
        print("Request Account Deletion tapped")
        // Navigate to deletion request flow
    }

    func handleHelpSupport() {
        print("Help & Support tapped")
        // Show support options
    }

    // MARK: - LOGOUT CONFIRMATION

    func confirmLogout() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
            self.performLogout()
        }))

        present(alert, animated: true)
    }

    // MARK: - LOGOUT PROCESS

    func performLogout() {

        // Remove saved role
        UserDefaults.standard.removeObject(forKey: "UserRole")

        // Navigate back to onboarding
        let onboardingVC = OnboardingPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        let nav = UINavigationController(rootViewController: onboardingVC)

        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(nav)
        }
    }
}
