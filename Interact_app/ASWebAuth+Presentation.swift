//
//  ASWebAuth+Presentation.swift
//  Interact_app
//
//  Created by admin56 on 11/12/25.
//
import UIKit
import AuthenticationServices

extension UIViewController: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? UIWindow()
    }
}
