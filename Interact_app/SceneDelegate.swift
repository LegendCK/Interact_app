//
//  SceneDelegate.swift
//  Interact_app
//
//  Created by admin56 on 06/11/25.
//

import UIKit

enum UserRole: String {
    case organizer
    case participant
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        // Decide initial root based on saved role
        if let savedRoleString = UserDefaults.standard.string(forKey: "UserRole"),
           let savedRole = UserRole(rawValue: savedRoleString) {

            switch savedRole {
            case .organizer:
                let organizerHome = MainTabBarController()
                window?.rootViewController = organizerHome

            case .participant:
                let participantHome = ParticipantMainTabBarController()
                window?.rootViewController = participantHome
            }

        } else {
            // No saved role — show onboarding
            let onboardingVC = OnboardingPageViewController(
                transitionStyle: .scroll,
                navigationOrientation: .horizontal,
                options: nil
            )
            let nav = UINavigationController(rootViewController: onboardingVC)
            window?.rootViewController = nav
        }

        window?.makeKeyAndVisible()

        // Add hidden dev reset gesture
        addDevResetGesture()
    }

    // MARK: - Hidden Developer Reset
    private func addDevResetGesture() {
        guard let window = self.window else { return }

        let tripleTap = UITapGestureRecognizer(target: self, action: #selector(devReset))
        tripleTap.numberOfTapsRequired = 3
        tripleTap.cancelsTouchesInView = false  // so it doesn't block real UI interaction

        window.addGestureRecognizer(tripleTap)
    }

    @objc private func devReset() {
        print("DEV RESET TRIGGERED — Clearing saved user role")

        // Clear saved login data
        UserDefaults.standard.removeObject(forKey: "UserRole")

        // Return to onboarding
        let onboardingVC = OnboardingPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        let nav = UINavigationController(rootViewController: onboardingVC)

        changeRootViewController(nav, animated: true)
    }

    // MARK: - Smooth Root Change
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else { return }
        // If already the same type, just animate to it to avoid flash
        window.rootViewController = vc

        if animated {
            UIView.transition(
                with: window,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: nil,
                completion: nil
            )
        }
    }


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

