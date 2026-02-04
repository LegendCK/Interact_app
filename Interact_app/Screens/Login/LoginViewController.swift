//
//  LoginViewController.swift
//  Interact_app
//

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textLabel1: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var emailAddressErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var loginButton: ButtonComponent!
    @IBOutlet weak var loginWithAppleButton: ButtonComponent!
    @IBOutlet weak var loginWithGoogleButton: ButtonComponent!
    @IBOutlet weak var forgetPasswordButton: UIButton!

    // Access auth manager
    var authManager: AuthManager? {
        if let scene = UIApplication.shared.connectedScenes.first,
           let delegate = scene.delegate as? SceneDelegate {
            return delegate.authManager
        }
        return nil
    }

    // Spinner
    private var spinner: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPasswordToggle()
        setupButtons()
        setupMainTitle()
        setupSignUpLabel()
        setupTextFields()
    }

    // MARK: - Password Toggle
    private func setupPasswordToggle() {
        let eyeButton = UIButton(type: .system)

        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "eye.slash.fill")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)

        eyeButton.configuration = config
        eyeButton.tintColor = .systemGray
        eyeButton.addTarget(self, action: #selector(didTapToggleEye(_:)), for: .touchUpInside)

        passwordTextField.rightView = eyeButton
        passwordTextField.rightViewMode = .always
        passwordTextField.isSecureTextEntry = true
    }

    @objc private func didTapToggleEye(_ sender: UIButton) {
        guard var config = sender.configuration else { return }
        let wasShowing = !passwordTextField.isSecureTextEntry

        let selectedRange = passwordTextField.selectedTextRange
        passwordTextField.isSecureTextEntry.toggle()

        // Fix cursor jump
        let txt = passwordTextField.text
        passwordTextField.text = ""
        passwordTextField.text = txt
        if let rng = selectedRange { passwordTextField.selectedTextRange = rng }

        config.image = UIImage(systemName: wasShowing ? "eye.slash.fill" : "eye.fill")
        sender.configuration = config
    }

    // MARK: - Forgot Password
    @IBAction func forgetPasswordOnTap(_ sender: Any) {
        let vc = ForgotPasswordViewController(nibName: "ForgotPasswordViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Buttons Setup
    private func setupButtons() {
        loginButton.configure(title: "Login", backgroundColor: .systemBlue)
        loginButton.onTap = { [weak self] in self?.loginTapped() }

        loginWithAppleButton.configure(
            title: "Continue with Apple",
            backgroundColor: .black,
            font: .systemFont(ofSize: 17, weight: .semibold),
            image: UIImage(systemName: "apple.logo")
        )

        loginWithGoogleButton.configure(
            title: "Continue with Google",
            titleColor: .black,
            backgroundColor: .white,
            font: .systemFont(ofSize: 17, weight: .semibold),
            image: UIImage(named: "googleIcon"),
            borderColor: UIColor.systemGray4,
            borderWidth: 1
        )

        loginWithGoogleButton.onTap = { [weak self] in self?.loginWithGoogleTapped() }
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

    // MARK: - Google Login
    private func loginWithGoogleTapped() {
        guard let auth = authManager else {
            presentAlert(title: "Internal Error", message: "Auth manager not available.")
            return
        }

        loginWithGoogleButton.button.isEnabled = false
        showLoading(true)

        auth.signInWithGoogle(
            redirectTo: "interact://auth/callback",
            presentationContext: self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.loginWithGoogleButton.button.isEnabled = true
                self?.showLoading(false)

                switch result {
                case .success(_):
                    print("Google login SUCCESS")
                    // Google accounts are auto-verified, check profile and route
                    self?.checkProfileAndRoute()

                case .failure(let error):
                    print("Google login failed:", error)
                    self?.presentAlert(title: "Google Login Failed", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Text Fields Setup
    private func setupTextFields() {
        emailAddressErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true

        let fields = [emailAddressTextField, passwordTextField]

        for tf in fields {
            tf?.delegate = self
            tf?.borderStyle = .none
            tf?.layer.borderColor = UIColor.systemGray4.cgColor
            tf?.layer.borderWidth = 1
            tf?.layer.cornerRadius = 10

            let padding = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
            tf?.leftView = padding
            tf?.leftViewMode = .always

            tf?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }

    @objc private func textFieldDidChange() { validateInputs(showErrors: false) }

    @discardableResult
    private func validateInputs(showErrors: Bool) -> Bool {
        var valid = true

        if let email = emailAddressTextField.text, email.isValidEmail() {
            emailAddressErrorLabel.isHidden = true
            emailAddressTextField.layer.borderColor = UIColor.systemGray4.cgColor
        } else {
            valid = false
            if showErrors {
                emailAddressErrorLabel.text = "Please enter a valid email"
                emailAddressErrorLabel.isHidden = false
                emailAddressTextField.layer.borderColor = UIColor.systemRed.cgColor
            }
        }

        if let pass = passwordTextField.text, pass.count >= 6 {
            passwordErrorLabel.isHidden = true
            passwordTextField.layer.borderColor = UIColor.systemGray4.cgColor
        } else {
            valid = false
            if showErrors {
                passwordErrorLabel.text = "Password must be at least 6 characters"
                passwordErrorLabel.isHidden = false
                passwordTextField.layer.borderColor = UIColor.systemRed.cgColor
            }
        }

        return valid
    }

    // MARK: - Email/Password Login
    // MARK: - Email/Password Login
    private func loginTapped() {
        view.endEditing(true)

        guard validateInputs(showErrors: true) else { return }
        guard let auth = authManager else {
            presentAlert(title: "Internal error", message: "Auth Manager missing")
            return
        }

        let email = emailAddressTextField.text!.lowercased()
        let password = passwordTextField.text!

        loginButton.button.isEnabled = false
        showLoading(true)

        auth.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.loginButton.button.isEnabled = true
                self.showLoading(false)

                switch result {
                case .success(_):
                    print("Login SUCCESS")
                    // Check if email is verified (manual login only)
                    self.checkEmailVerificationAndRoute()

                case .failure(let error):
                    // Check if error is due to unverified email
                    let errorMessage = error.localizedDescription
                    
                    print("Login error:", errorMessage) // Debug
                    
                    // Check for status code 400 AND "Email not confirmed" message
                    if errorMessage.contains("Email not confirmed") ||
                       errorMessage.contains("email not confirmed") ||
                       errorMessage.contains("400") && errorMessage.lowercased().contains("email") {
                        // Email not verified - show specific alert with resend option
                        print("Email not confirmed - showing resend alert")
                        self.showEmailNotVerifiedAlert()
                    } else {
                        // Other error (wrong password, user not found, etc.)
                        self.presentAlert(title: "Login Failed", message: errorMessage)
                    }
                }
            }
        }
    }
    // MARK: - Check Email Verification (Manual Login Only)
    private func checkEmailVerificationAndRoute() {
        guard let auth = authManager else { return }

        showLoading(true)

        auth.checkEmailVerified { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.showLoading(false)

                switch result {
                case .success(let isVerified):
                    if isVerified {
                        print("Email is verified, checking profile...")
                        self.checkProfileAndRoute()
                    } else {
                        print("Email NOT verified")
                        self.showEmailNotVerifiedAlert()
                    }

                case .failure(let error):
                    print("Email verification check failed:", error)
                    self.presentAlert(title: "Error", message: "Unable to verify email status. Please try again.")
                }
            }
        }
    }

    // MARK: - Show Email Not Verified Alert
    private func showEmailNotVerifiedAlert() {
        let alert = UIAlertController(
            title: "Email Not Verified",
            message: "Please verify your email address before logging in. Check your inbox for the verification link.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Resend Email", style: .default) { [weak self] _ in
            self?.resendVerificationEmail()
        })

        alert.addAction(UIAlertAction(title: "OK", style: .cancel))

        present(alert, animated: true)
    }

    // MARK: - Resend Verification Email
    private func resendVerificationEmail() {
        guard let auth = authManager,
              let email = emailAddressTextField.text?.lowercased() else {
            return
        }

        showLoading(true)

        auth.resendVerificationEmail(email: email) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.showLoading(false)

                switch result {
                case .success():
                    self.presentAlert(title: "Email Sent", message: "Verification email has been resent. Please check your inbox.")

                case .failure(let error):
                    self.presentAlert(title: "Resend Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Check Profile and Route
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

                        if let roleStr = role, !roleStr.isEmpty {
                            if isProfileSetup {
                                // Profile complete - navigate to home
                                print("Profile complete, role: \(roleStr)")
                                if let userRole = UserRole(rawValue: roleStr) {
                                    UserDefaults.standard.set(roleStr, forKey: "UserRole")
                                    self.routeToHome(role: userRole)
                                } else {
                                    self.presentAlert(title: "Error", message: "Invalid role in profile")
                                }
                            } else {
                                // Role selected but profile not setup - go to profile setup
                                print("Role selected but profile incomplete, navigating to profile setup")
                                if let userRole = UserRole(rawValue: roleStr) {
                                    UserDefaults.standard.set(roleStr, forKey: "UserRole")
                                    self.navigateToProfileSetup(role: userRole)
                                } else {
                                    self.presentAlert(title: "Error", message: "Invalid role in profile")
                                }
                            }
                        } else {
                            // No role - go to role selection
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
                    self.presentAlert(title: "Error", message: "Unable to load profile. Please try again.")
                }
            }
        }
    }

    // MARK: - Navigation
    private func navigateToRoleSelection() {
        let roleVC = RoleSelectionViewController(nibName: "RoleSelectionViewController", bundle: nil)
        navigationController?.pushViewController(roleVC, animated: true)
    }

    // ADD THIS NEW METHOD
    private func navigateToProfileSetup(role: UserRole) {
        switch role {
        case .organizer:
            let vc = OrgProfileSetupViewController(nibName: "OrgProfileSetupViewController", bundle: nil)
            vc.userRole = .organizer
            navigationController?.pushViewController(vc, animated: true)
            
        case .participant:
            let vc = ParticipantProfileSetupViewController(nibName: "ParticipantProfileSetupViewController", bundle: nil)
            vc.userRole = .participant
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func routeToHome(role: UserRole) {
        guard let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            return
        }

        scene.routeToHome(role: role)
    }


    // MARK: - Labels
    private func setupMainTitle() {
        let text = "Log in to Interact"
        let colored = NSMutableAttributedString(string: text)
        if let range = text.range(of: "Interact") {
            let ns = NSRange(range, in: text)
            colored.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: ns)
        }
        textLabel1.attributedText = colored
    }

    private func setupSignUpLabel() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(signUpTapped))
        signUpLabel.isUserInteractionEnabled = true
        signUpLabel.addGestureRecognizer(tap)
    }

    @objc private func signUpTapped() {
        let signupVC = SignupViewController(nibName: "SignupViewController", bundle: nil)
        navigationController?.pushViewController(signupVC, animated: true)
    }

    // MARK: - Alerts
    private func presentAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - Email validation
extension String {
    func isValidEmail() -> Bool {
        let reg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", reg).evaluate(with: self)
    }
}
