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

    // Expose authManager to the app so controllers can retrieve it (or inject)
    var authManager: AuthManager?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Initialize Supabase services (fail gracefully)
        do {
            let config = try SupabaseConfig()
            let client = SupabaseClient(config: config)
            let keychain = KeychainService()
            self.authManager = AuthManager(client: client, keychain: keychain)
        } catch {
            // If config fails, fall through and show error UI below
            print("Supabase config error: \(error)")
        }

        window = UIWindow(windowScene: windowScene)

        // If the app was launched via a URL (cold start), handle it after services are ready.
        if let incoming = connectionOptions.urlContexts.first?.url {
            // forward to auth manager and then finish UI setup in the completion
            print("Launched from URL:", incoming.absoluteString)
            authManager?.handleRedirect(url: incoming) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        // If redirect produced a valid session, route user accordingly
                        self?.routeAfterSignIn()
                    case .failure(let err):
                        // Log error and continue to normal initial flow
                        print("HandleRedirect at launch failed:", err.localizedDescription)
                        self?.setupInitialRootNormally()
                    }
                }
            }
        } else {
            // Normal startup flow
            setupInitialRootNormally()
        }

        window?.makeKeyAndVisible()

        // Add hidden dev reset gesture
        addDevResetGesture()
    }

    // MARK: - Default initial root setup (keeps your original logic)
    private func setupInitialRootNormally() {
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
    }

    // MARK: - Handle incoming deep links (forward to AuthManager)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let ctx = URLContexts.first else { return }
        let url = ctx.url
        print("SceneDelegate received URL:", url.absoluteString)

        // Forward to auth manager and upon success route into the app
        authManager?.handleRedirect(url: url) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.routeAfterSignIn()
                case .failure(let err):
                    print("handleRedirect failed:", err.localizedDescription)
                    // Optionally show an alert or ignore
                }
            }
        }
    }

    // MARK: - Routing after sign-in
    /// Called when we have a valid persisted session (from OAuth redirect or sign-in).
    /// If the user already has a saved role, we set home; otherwise show role selection to continue onboarding.
    private func routeAfterSignIn() {
        // If role already saved, go straight to the appropriate home
        if let savedRoleString = UserDefaults.standard.string(forKey: "UserRole"),
           let savedRole = UserRole(rawValue: savedRoleString) {
            switch savedRole {
            case .organizer:
                let organizerHome = MainTabBarController()
                changeRootViewController(organizerHome)
            case .participant:
                let participantHome = ParticipantMainTabBarController()
                changeRootViewController(participantHome)
            }
            return
        }

        // No saved role — push RoleSelection so user picks org/participant and finishes profile
        let roleSelection = RoleSelectionViewController(nibName: "RoleSelectionViewController", bundle: nil)
        let nav = UINavigationController(rootViewController: roleSelection)
        changeRootViewController(nav)
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
        // replace root
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

