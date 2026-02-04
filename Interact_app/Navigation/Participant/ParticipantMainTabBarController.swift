import UIKit

final class ParticipantMainTabBarController: UITabBarController {

    // MARK: - Dependencies
    private let authManager: AuthManager

    // MARK: - Init

    init(authManager: AuthManager) {
        self.authManager = authManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Use init(authManager:) instead")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }

    // MARK: - Setup Tabs

    private func setupTabs() {

        let exploreVC = ParticipantExplore1ViewController()
        let eventsVC = ParticipantEventsViewController()
        let leaderboardVC = ParticipantLeaderboardViewController()
        let chatVC = ParticipantChatsViewController()

        // ✅ Profile VC with dependency injection
        let profileVC = ParticipantProfileViewController(
            nibName: "ParticipantProfileViewController",
            bundle: nil
        )
        profileVC.viewModel = ParticipantProfileViewModel(
            authManager: authManager
        )

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

        viewControllers = [
            exploreNav,
            eventsNav,
            leaderboardNav,
            chatNav,
            profileNav
        ]
    }

    // MARK: - Appearance

    private func setupAppearance() {
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .gray
    }
}
