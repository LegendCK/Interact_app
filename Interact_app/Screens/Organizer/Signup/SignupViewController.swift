////
////  SignupViewController.swift
////  Interact_app
////
////  Created by admin56 on 07/11/25.
////
//
//import UIKit
//
//class SignupViewController: UIViewController, UITextFieldDelegate {
//
//    // Role passed from RoleSelectionViewController
//    var userRole: UserRole?
//
//    @IBOutlet weak var textLabel1: UILabel!
//    @IBOutlet weak var alreadyHaveAccLabel: UILabel!
//    @IBOutlet weak var emailAddressTextField: UITextField!
//    @IBOutlet weak var createPasswordTextField: UITextField!
//    @IBOutlet weak var confirmPasswordTextField: UITextField!
//    @IBOutlet weak var verifyEmailButton: ButtonComponent!
//    @IBOutlet weak var signUpWithAppleButton: ButtonComponent!
//    @IBOutlet weak var signUpWithGoogleButton: ButtonComponent!
//
//    // authManager fetched from SceneDelegate if needed
//    var authManager: AuthManager? {
//        if let appScene = UIApplication.shared.connectedScenes.first,
//           let sceneDelegate = appScene.delegate as? SceneDelegate {
//            return sceneDelegate.authManager
//        }
//        return nil
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setupTextFields()
//        setupMainTitle()
//        setupButtons()
//
//        // Hook sign up action to actually call signUp
//        verifyEmailButton.configure(title: "Sign up")
//        verifyEmailButton.onTap = { [weak self] in
//            self?.performSignUpAndShowVerify()
//        }
//
//        let tap = UITapGestureRecognizer(target: self, action: #selector(backToLoginTapped))
//        alreadyHaveAccLabel.isUserInteractionEnabled = true
//        alreadyHaveAccLabel.addGestureRecognizer(tap)
//    }
//
//    @objc func backToLoginTapped() {
//        navigateBackToLogin()
//    }
//
//    // MARK: - Text Fields Setup
//    private func setupTextFields() {
//        let textFields = [
//            emailAddressTextField,
//            createPasswordTextField,
//            confirmPasswordTextField
//        ]
//
//        for textField in textFields {
//            guard let field = textField else { continue }
//            field.delegate = self
//
//            field.borderStyle = .none
//            field.layer.borderColor = UIColor.systemGray4.cgColor
//            field.layer.borderWidth = 1
//            field.layer.cornerRadius = 10
//
//            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.height))
//            field.leftView = leftPaddingView
//            field.leftViewMode = .always
//        }
//
//        addPasswordToggle(to: createPasswordTextField)
//        addPasswordToggle(to: confirmPasswordTextField)
//    }
//
//    private func setupMainTitle() {
//        let fullText = "Sign up to Interact"
//        let blueWord = "Interact"
//
//        let attributedString = NSMutableAttributedString(string: fullText)
//
//        if let range = fullText.range(of: blueWord) {
//            let nsRange = NSRange(range, in: fullText)
//            attributedString.addAttribute(.foregroundColor,
//                                          value: UIColor.systemBlue,
//                                          range: nsRange)
//        }
//
//        textLabel1.attributedText = attributedString
//    }
//
//    // MARK: - Password Toggle
//    private func addPasswordToggle(to textField: UITextField) {
//        let button = UIButton(type: .system)
//
//        var config = UIButton.Configuration.plain()
//        config.image = UIImage(systemName: "eye.slash.fill")
//        config.preferredSymbolConfigurationForImage =
//            UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
//        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)
//
//        button.configuration = config
//        button.tintColor = .systemGray
//
//        button.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
//
//        textField.rightView = button
//        textField.rightViewMode = .always
//        textField.isSecureTextEntry = true
//    }
//
//    @objc private func togglePasswordVisibility(_ sender: UIButton) {
//        guard let tf = [createPasswordTextField, confirmPasswordTextField].first(where: {
//            $0?.rightView == sender
//        }) ?? nil else { return }
//
//        guard var config = sender.configuration else { return }
//
//        let wasResponder = tf.isFirstResponder
//        let range = tf.selectedTextRange
//
//        tf.isSecureTextEntry.toggle()
//
//        // Fix cursor jump
//        let text = tf.text
//        tf.text = nil
//        tf.text = text
//        if let r = range { tf.selectedTextRange = r }
//        if wasResponder { tf.becomeFirstResponder() }
//
//        config.image = UIImage(systemName: tf.isSecureTextEntry ? "eye.slash.fill" : "eye.fill")
//        sender.configuration = config
//    }
//
//    private func setupButtons() {
//        signUpWithAppleButton.configure(
//            title: "Continue with Apple",
//            backgroundColor: .black,
//            font: .systemFont(ofSize: 17, weight: .semibold),
//            image: UIImage(systemName: "apple.logo")
//        )
//
//        signUpWithGoogleButton.configure(
//            title: "Continue with Google",
//            titleColor: .black,
//            backgroundColor: .white,
//            font: .systemFont(ofSize: 17, weight: .semibold),
//            image: UIImage(named: "googleIcon"),
//            borderColor: UIColor.systemGray4,
//            borderWidth: 1
//        )
//    }
//
//    // MARK: - Sign Up Flow
//    private func performSignUpAndShowVerify() {
//        guard let email = emailAddressTextField.text?.lowercased(), email.isValidEmail(),
//              let pass = createPasswordTextField.text, pass.count >= 6,
//              let confirm = confirmPasswordTextField.text, confirm == pass else {
//            presentAlert(title: "Invalid input", message: "Please ensure email is valid and passwords match (6+ chars).")
//            return
//        }
//
//        guard let auth = authManager else {
//            presentAlert(title: "Internal error", message: "Auth manager not available")
//            return
//        }
//
//        // If your ButtonComponent exposes `button` subview use that, otherwise adjust accordingly
//        verifyEmailButton.button.isEnabled = false
//
//        auth.signUp(email: email, password: pass) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.verifyEmailButton.button.isEnabled = true
//                switch result {
//                case .success():
//                    // Move to the verify screen which tells the user to check email
//                    let verifyVC = VerifyAccountViewController(nibName: "VerifyAccountViewController", bundle: nil)
//                    self?.navigationController?.pushViewController(verifyVC, animated: true)
//                case .failure(let err):
//                    self?.presentAlert(title: "Sign Up Failed", message: err.localizedDescription)
//                }
//            }
//        }
//    }
//
//    // Renamed to avoid collision with other goToLoginScreen() definitions in the project
//    private func navigateBackToLogin() {
//        navigationController?.popViewController(animated: true)
//    }
//
//    private func presentAlert(title: String, message: String) {
//        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        a.addAction(UIAlertAction(title: "OK", style: .default))
//        present(a, animated: true)
//    }
//}

//
//  SignupViewController.swift
//  Interact_app
//
//  Created by admin56 on 07/11/25.
//

import UIKit
import AuthenticationServices

class SignupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textLabel1: UILabel!
    @IBOutlet weak var alreadyHaveAccLabel: UILabel!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var createPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var verifyEmailButton: ButtonComponent!
    @IBOutlet weak var signUpWithAppleButton: ButtonComponent!
    @IBOutlet weak var signUpWithGoogleButton: ButtonComponent!

    // authManager fetched from SceneDelegate
    var authManager: AuthManager? {
        if let appScene = UIApplication.shared.connectedScenes.first,
           let sceneDelegate = appScene.delegate as? SceneDelegate {
            return sceneDelegate.authManager
        }
        return nil
    }

    // Spinner
    private var spinner: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTextFields()
        setupMainTitle()
        setupButtons()

        // Hook sign up action
        verifyEmailButton.configure(title: "Sign up")
        verifyEmailButton.onTap = { [weak self] in
            self?.performSignUpAndShowVerify()
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(backToLoginTapped))
        alreadyHaveAccLabel.isUserInteractionEnabled = true
        alreadyHaveAccLabel.addGestureRecognizer(tap)
    }

    @objc func backToLoginTapped() {
        navigateBackToLogin()
    }

    // MARK: - Loading Indicator
    private func showLoading(_ show: Bool) {
        if show {
            if spinner == nil {
                let s = UIActivityIndicatorView(style: .large)
                s.translatesAutoresizingMaskIntoConstraints = false
                s.hidesWhenStopped = true
                view.addSubview(s)
                NSLayoutConstraint.activate([
                    s.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    s.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                ])
                spinner = s
            }
            spinner?.startAnimating()
            view.isUserInteractionEnabled = false
        } else {
            spinner?.stopAnimating()
            view.isUserInteractionEnabled = true
        }
    }

    // MARK: - Text Fields Setup
    private func setupTextFields() {
        let textFields = [
            emailAddressTextField,
            createPasswordTextField,
            confirmPasswordTextField
        ]

        for textField in textFields {
            guard let field = textField else { continue }
            field.delegate = self

            field.borderStyle = .none
            field.layer.borderColor = UIColor.systemGray4.cgColor
            field.layer.borderWidth = 1
            field.layer.cornerRadius = 10

            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.height))
            field.leftView = leftPaddingView
            field.leftViewMode = .always
        }

        addPasswordToggle(to: createPasswordTextField)
        addPasswordToggle(to: confirmPasswordTextField)
    }

    private func setupMainTitle() {
        let fullText = "Sign up to Interact"
        let blueWord = "Interact"

        let attributedString = NSMutableAttributedString(string: fullText)

        if let range = fullText.range(of: blueWord) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.foregroundColor,
                                          value: UIColor.systemBlue,
                                          range: nsRange)
        }

        textLabel1.attributedText = attributedString
    }

    // MARK: - Password Toggle
    private func addPasswordToggle(to textField: UITextField) {
        let button = UIButton(type: .system)

        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "eye.slash.fill")
        config.preferredSymbolConfigurationForImage =
            UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)

        button.configuration = config
        button.tintColor = .systemGray

        button.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)

        textField.rightView = button
        textField.rightViewMode = .always
        textField.isSecureTextEntry = true
    }

    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        guard let tf = [createPasswordTextField, confirmPasswordTextField].first(where: {
            $0?.rightView == sender
        }) ?? nil else { return }

        guard var config = sender.configuration else { return }

        let wasResponder = tf.isFirstResponder
        let range = tf.selectedTextRange

        tf.isSecureTextEntry.toggle()

        // Fix cursor jump
        let text = tf.text
        tf.text = nil
        tf.text = text
        if let r = range { tf.selectedTextRange = r }
        if wasResponder { tf.becomeFirstResponder() }

        config.image = UIImage(systemName: tf.isSecureTextEntry ? "eye.slash.fill" : "eye.fill")
        sender.configuration = config
    }

    private func setupButtons() {
        signUpWithAppleButton.configure(
            title: "Continue with Apple",
            backgroundColor: .black,
            font: .systemFont(ofSize: 17, weight: .semibold),
            image: UIImage(systemName: "apple.logo")
        )

        signUpWithGoogleButton.configure(
            title: "Continue with Google",
            titleColor: .black,
            backgroundColor: .white,
            font: .systemFont(ofSize: 17, weight: .semibold),
            image: UIImage(named: "googleIcon"),
            borderColor: UIColor.systemGray4,
            borderWidth: 1
        )

        // Wire Google button action to start OAuth flow
        signUpWithGoogleButton.onTap = { [weak self] in
            self?.startGoogleSignup()
        }
    }

    // MARK: - Sign Up Flow (email/password)
    private func performSignUpAndShowVerify() {
        guard let email = emailAddressTextField.text?.lowercased(), email.isValidEmail(),
              let pass = createPasswordTextField.text, pass.count >= 6,
              let confirm = confirmPasswordTextField.text, confirm == pass else {
            presentAlert(title: "Invalid input", message: "Please ensure email is valid and passwords match (6+ chars).")
            return
        }

        guard let auth = authManager else {
            presentAlert(title: "Internal error", message: "Auth manager not available")
            return
        }

        verifyEmailButton.button.isEnabled = false
        showLoading(true)

        auth.signUp(email: email, password: pass) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.verifyEmailButton.button.isEnabled = true
                self.showLoading(false)
                
                switch result {
                case .success():
                    print("Signup SUCCESS - email verification required")
                    // Move to verify screen which tells user to check email
                    let verifyVC = VerifyAccountViewController(nibName: "VerifyAccountViewController", bundle: nil)
                    verifyVC.userEmail = email // Pass email for resend functionality
                    self.navigationController?.pushViewController(verifyVC, animated: true)
                    
                case .failure(let err):
                    self.presentAlert(title: "Sign Up Failed", message: err.localizedDescription)
                }
            }
        }
    }

    // MARK: - Google Signup Flow
    private func startGoogleSignup() {
        guard let auth = authManager else {
            presentAlert(title: "Internal error", message: "Auth manager not available")
            return
        }

        // disable the button to avoid duplicate taps
        signUpWithGoogleButton.button.isEnabled = false
        showLoading(true)

        auth.signInWithGoogle(redirectTo: "interact://auth/callback", presentationContext: self) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.signUpWithGoogleButton.button.isEnabled = true
                self.showLoading(false)

                switch result {
                case .success(_):
                    print("Google signup SUCCESS - email auto-verified")
                    // Google accounts are auto-verified, check profile and route
                    self.checkProfileAndRoute()

                case .failure(let err):
                    self.presentAlert(title: "Google Sign Up Failed", message: err.localizedDescription)
                }
            }
        }
    }

    // MARK: - Check Profile and Route (Google only)
    private func checkProfileAndRoute() {
        guard let auth = authManager else { return }

        showLoading(true)

        auth.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.showLoading(false)

                switch result {
                case .success(let profile):
                    if let profile = profile {
                        // Profile exists - check role and is_profile_setup
                        let role = profile["role"] as? String
                        let isProfileSetup = profile["is_profile_setup"] as? Bool ?? false

                        if let roleStr = role, !roleStr.isEmpty, isProfileSetup {
                            // Profile complete - navigate to home
                            print("Profile complete, role: \(roleStr)")
                            if let userRole = UserRole(rawValue: roleStr) {
                                UserDefaults.standard.set(roleStr, forKey: "UserRole")
                                self.routeToHome(role: userRole)
                            } else {
                                self.presentAlert(title: "Error", message: "Invalid role in profile")
                            }
                        } else {
                            // Profile incomplete - go to role selection
                            print("Profile incomplete, navigating to role selection")
                            self.navigateToRoleSelection()
                        }
                    } else {
                        // No profile found - go to role selection
                        print("No profile found, navigating to role selection")
                        self.navigateToRoleSelection()
                    }

                case .failure(let error):
                    print("Failed to fetch profile:", error)
                    self.presentAlert(title: "Error", message: "Unable to load profile. Please try again.")
                }
            }
        }
    }

    // MARK: - Navigation
    private func navigateToRoleSelection() {
        let roleSelectionVC = RoleSelectionViewController(nibName: "RoleSelectionViewController", bundle: nil)
        navigationController?.pushViewController(roleSelectionVC, animated: true)
    }

    private func routeToHome(role: UserRole) {
        guard let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            return
        }

        scene.routeToHome(role: role)
    }

    private func navigateBackToLogin() {
        navigationController?.popViewController(animated: true)
    }

    private func presentAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
