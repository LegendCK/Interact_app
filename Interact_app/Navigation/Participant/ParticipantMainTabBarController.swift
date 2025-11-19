//
//  ParticipantMainTabBarController.swift
//  Interact-UIKit
//
//  Created by admin73 on 07/11/25.
//

import UIKit

class ParticipantMainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }

    private func setupTabs() {
        // Create view controllers for each tab
        let exploreVC = ParticipantExplore1ViewController()
        let eventsVC = ParticipantEventsViewController()
        let leaderboardVC = ParticipantLeaderboardViewController()
        let chatVC = ParticipantChatsViewController()
        let profileVC = ParticipantProfileViewController()

        // Embed in navigation controllers
        let exploreNav = UINavigationController(rootViewController: exploreVC)
        let eventsNav = UINavigationController(rootViewController: eventsVC)
        let leaderboardNav = UINavigationController(rootViewController: leaderboardVC)
        let chatNav = UINavigationController(rootViewController: chatVC)
        let profileNav = UINavigationController(rootViewController: profileVC)

        // Configure tab bar items
        exploreNav.tabBarItem = UITabBarItem(
            title: "Explore",
            image: UIImage(systemName: "sparkles"),
            selectedImage: UIImage(systemName: "sparkles")
        )

        eventsNav.tabBarItem = UITabBarItem(
            title: "Events",
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar")
        )

        leaderboardNav.tabBarItem = UITabBarItem(
            title: "Leaderboard",
            image: UIImage(systemName: "trophy"),
            selectedImage: UIImage(systemName: "trophy.fill")
        )

        chatNav.tabBarItem = UITabBarItem(
            title: "Chat",
            image: UIImage(systemName: "bubble.left.and.text.bubble.right"),
            selectedImage: UIImage(systemName: "bubble.left.and.text.bubble.right.fill")
        )

        profileNav.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.circle"),
            selectedImage: UIImage(systemName: "person.circle.fill")
        )

        // Assign to tab bar
        self.viewControllers = [
            exploreNav,
            eventsNav,
            leaderboardNav,
            chatNav,
            profileNav
        ]
    }

    private func setupAppearance() {
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .gray
    }
}
