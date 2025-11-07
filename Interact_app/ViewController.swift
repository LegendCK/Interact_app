//
//  ViewController.swift
//  Interact_app
//
//  Created by admin56 on 06/11/25.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.


    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            showLoginScreen()
        }
        
//        private func showLoginScreen() {
//            let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
//            loginVC.modalPresentationStyle = .fullScreen
//            present(loginVC, animated: true)
//        }
    private func showLoginScreen() {
        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }

}

