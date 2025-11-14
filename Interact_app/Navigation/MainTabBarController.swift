//
//  MainTabBarController.swift
//  Interact-UIKit
//
//  Created by admin73 on 07/11/25.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }

    private func setupTabs() {
        // Create the view controllers
        let homeVC = HomeScreenViewController()
        let eventsVC = EventsScreenViewController()
        let profileVC = ProfileScreenViewController()

        // Embed each in a UINavigationController for consistent top bar
        let homeNav = UINavigationController(rootViewController: homeVC)
        let eventsNav = UINavigationController(rootViewController: eventsVC)
        let profileNav = UINavigationController(rootViewController: profileVC)

        // Configure tab bar items
        homeNav.tabBarItem = UITabBarItem(title: "Home",
                                          image: UIImage(systemName: "house"),
                                          selectedImage: UIImage(systemName: "house.fill"))
        eventsNav.tabBarItem = UITabBarItem(title: "Events",
                                            image: UIImage(systemName: "calendar"),
                                            selectedImage: UIImage(systemName: "calendar"))
        profileNav.tabBarItem = UITabBarItem(title: "Profile",
                                             image: UIImage(systemName: "person"),
                                             selectedImage: UIImage(systemName: "person.fill"))

        // Assign to tab bar
        self.viewControllers = [homeNav, eventsNav, profileNav]
    }

    private func setupAppearance() {
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .gray
//        tabBar.backgroundColor = .systemBackground
    }
}

