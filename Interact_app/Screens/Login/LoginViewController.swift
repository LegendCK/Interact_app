//
//  LoginViewController.swift
//  Interact_app
//
//  Created by admin56 on 07/11/25.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var textLabel1: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    
    @IBOutlet weak var loginWithAppleButton: UIButton!
    @IBOutlet weak var loginWithGoogleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMainTitle()
        setupSignUpLabel()
    }
    
    // MARK: - Setup Title Label ("Log in to Interact")
    private func setupMainTitle() {
        let fullText = "Log in to Interact"
        let blueWord = "Interact"
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        if let range = fullText.range(of: blueWord) {
            let nsRange = NSRange(range, in: fullText)
            let blueColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
            attributedString.addAttribute(.foregroundColor, value: blueColor, range: nsRange)
        }
        
        textLabel1.attributedText = attributedString
    }
    
    // MARK: - Setup Sign Up Label ("Don’t have an account? Sign up")
    private func setupSignUpLabel() {
        let fullText = "Don’t have an account? Sign up"
        let blueWord = "Sign up"
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        if let range = fullText.range(of: blueWord) {
            let nsRange = NSRange(range, in: fullText)
            let blueColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
            
            attributedString.addAttribute(.foregroundColor, value: blueColor, range: nsRange)
        }
        
        signUpLabel.attributedText = attributedString
        
        // Make it tappable
        let tap = UITapGestureRecognizer(target: self, action: #selector(signUpTapped))
        signUpLabel.isUserInteractionEnabled = true
        signUpLabel.addGestureRecognizer(tap)
    }
    
    // MARK: - Actions
    @objc private func signUpTapped() {
        // Navigate to Role Selection Screen (or directly signup)
        print("Sign Up tapped!")
           let roleVC = RoleSelectionViewController(nibName: "RoleSelectionViewController", bundle: nil)
           
           // Option 1: If using NavigationController
           navigationController?.pushViewController(roleVC, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
