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

    // Expose authManager to the app so controllers can retrieve it
    var authManager: AuthManager?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Initialize Supabase services (fail gracefully)
        do {
            let config = try SupabaseConfig()
            let client = SupabaseClient(config: config)

            // ✅ INJECT CLIENT INTO SERVICES
            EventService.shared.client = client      // <--- INSERT THIS
            ConnectionService.shared.client = client // <--- INSERT THIS
            ProfileService.shared.client = client    // <--- INSERT THIS
            TeamService.shared.client = client      

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
                        self?.checkProfileAndRoute()
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

    // MARK: - Default initial root setup
    private func setupInitialRootNormally() {
        // Check if user has active session
        if let auth = authManager, auth.currentSession != nil {
            // User has session - check profile status from Supabase
            print("Active session found, checking profile status...")
            checkProfileAndRoute()
        } else {
            // No session - show onboarding
            print("No active session, showing onboarding")
            showOnboarding()
        }
    }

    // MARK: - Check Profile and Route
    private func checkProfileAndRoute() {
        guard let auth = authManager else {
            showOnboarding()
            return
        }

        // Fetch profile from Supabase to check actual state
        auth.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let profile):
                    if let profile = profile {
                        // Profile exists - check role and is_profile_setup
                        let role = profile["role"] as? String
                        let isProfileSetup = profile["is_profile_setup"] as? Bool ?? false

                        print("Profile found - role: \(role ?? "nil"), setup: \(isProfileSetup)")

                        if let roleStr = role, !roleStr.isEmpty {
                            if isProfileSetup {
                                // Profile complete - navigate to home
                                if let userRole = UserRole(rawValue: roleStr) {
                                    UserDefaults.standard.set(roleStr, forKey: "UserRole")
                                    self.routeToHome(role: userRole)
                                } else {
                                    print("Invalid role in profile")
                                    self.showOnboarding()
                                }
                            } else {
                                // Role selected but profile not complete - go to profile setup
                                print("Profile incomplete, navigating to profile setup")
                                if let userRole = UserRole(rawValue: roleStr) {
                                    UserDefaults.standard.set(roleStr, forKey: "UserRole")
                                    self.navigateToProfileSetup(role: userRole)
                                } else {
                                    self.showOnboarding()
                                }
                            }
                        } else {
                            // No role set - go to role selection
                            print("No role set, navigating to role selection")
                            self.navigateToRoleSelection()
                        }
                    } else {
                        // No profile found - go to role selection
                        print("No profile found, navigating to role selection")
                        self.navigateToRoleSelection()
                    }

                case .failure(let error):
                    print("Failed to fetch profile:", error)
                    // On error, clear session and show onboarding
                    self.showOnboarding()
                }
            }
        }
    }

    // MARK: - Navigation Methods
    private func showOnboarding() {
        let onboardingVC = OnboardingPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        let nav = UINavigationController(rootViewController: onboardingVC)
        changeRootViewController(nav, animated: false)
    }

    private func navigateToRoleSelection() {
        let roleVC = RoleSelectionViewController(nibName: "RoleSelectionViewController", bundle: nil)
        let nav = UINavigationController(rootViewController: roleVC)
        changeRootViewController(nav, animated: false)
    }

    private func navigateToProfileSetup(role: UserRole) {
        switch role {
        case .organizer:
            let vc = OrgProfileSetupViewController(nibName: "OrgProfileSetupViewController", bundle: nil)
            vc.userRole = .organizer
            let nav = UINavigationController(rootViewController: vc)
            changeRootViewController(nav, animated: false)

        case .participant:
            let vc = ParticipantProfileSetupViewController(nibName: "ParticipantProfileSetupViewController", bundle: nil)
            vc.userRole = .participant
            let nav = UINavigationController(rootViewController: vc)
            changeRootViewController(nav, animated: false)
        }
    }

    private func routeToHome(role: UserRole) {
        switch role {
        case .organizer:
            changeRootViewController(MainTabBarController(), animated: false)
        case .participant:
            changeRootViewController(ParticipantMainTabBarController(), animated: false)
        }
    }

    // MARK: - Handle incoming deep links
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let ctx = URLContexts.first else { return }
        let url = ctx.url
        print("SceneDelegate received URL:", url.absoluteString)

        // Forward to auth manager and upon success route into the app
        authManager?.handleRedirect(url: url) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.checkProfileAndRoute()
                case .failure(let err):
                    print("handleRedirect failed:", err.localizedDescription)
                }
            }
        }
    }

    // MARK: - Hidden Developer Reset
    private func addDevResetGesture() {
        guard let window = self.window else { return }

        let tripleTap = UITapGestureRecognizer(target: self, action: #selector(devReset))
        tripleTap.numberOfTapsRequired = 3
        tripleTap.cancelsTouchesInView = false

        window.addGestureRecognizer(tripleTap)
    }

    @objc private func devReset() {
        print("DEV RESET TRIGGERED — Clearing saved user data")

        // Clear saved login data
        UserDefaults.standard.removeObject(forKey: "UserRole")
        
        // Sign out
        authManager?.signOut(serverSide: false) { _ in
            print("Signed out")
        }

        // Return to onboarding
        showOnboarding()
    }

    // MARK: - Smooth Root Change
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else { return }
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

