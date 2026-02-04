////
////  DeepLinkRouter.swift
////  Interact_app
////
////  Created by admin56 on 17/01/26.
////
//
//import UIKit
//
//enum DeepLinkRouter {
//
//    static func handle(url: URL, sceneDelegate: SceneDelegate) -> Bool {
//
//        // Auth callback
//        if url.absoluteString.contains("/auth/callback") {
//            sceneDelegate.authManager?.handleRedirect(url: url) { _ in
//                DispatchQueue.main.async {
//                    sceneDelegate.checkProfileAndRoute()
//                }
//            }
//            return true
//        }
//
//        // Profile deep link
//        if url.pathComponents.count >= 3,
//           url.pathComponents[1] == "profile" {
//
//            let token = url.pathComponents[2]
//            openPublicProfile(token: token, sceneDelegate: sceneDelegate)
//            return true
//        }
//
//        return false
//    }
//
//    private static func openPublicProfile(token: String, sceneDelegate: SceneDelegate) {
//        let vc = PublicProfileViewController(
//            nibName: "PublicProfileViewController",
//            bundle: nil
//        )
//        vc.qrToken = token
//
//        let nav = UINavigationController(rootViewController: vc)
//        sceneDelegate.changeRootViewController(nav)
//    }
//}
