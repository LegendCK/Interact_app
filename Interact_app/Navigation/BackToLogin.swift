//
//  BackToLogin.swift
//  Interact_app
//
//  Created by admin56 on 18/11/25.
//

import Foundation
import UIKit

extension UIViewController {
    func goToLoginScreen() {
        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        let nav = UINavigationController(rootViewController: loginVC)
        
        // SceneDelegate root change
        if let sceneDelegate = UIApplication.shared.connectedScenes
            .first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(nav)
        }
    }
}

