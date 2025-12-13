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

    // MARK: - Google Login
    private func loginWithGoogleTapped() {
        guard let auth = authManager else {
            presentAlert(title: "Internal Error", message: "Auth manager not available.")
            return
        }

        loginWithGoogleButton.button.isEnabled = false

        auth.signInWithGoogle(
            redirectTo: "interact://auth/callback",
            presentationContext: self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.loginWithGoogleButton.button.isEnabled = true

                switch result {
                case .success(_):
                    print("Google login SUCCESS")

                    // If role is already saved → go to home
                    if let saved = UserDefaults.standard.string(forKey: "UserRole"),
                       let role = UserRole(rawValue: saved) {
                        self?.routeToHome(role: role)
                    } else {
                        // No role → go to onboarding role selection
                        let roleVC = RoleSelectionViewController(nibName:"RoleSelectionViewController", bundle:nil)
                        self?.navigationController?.pushViewController(roleVC, animated:true)
                    }

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

        auth.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.loginButton.button.isEnabled = true

                switch result {
                case .success(_):
                    if let saved = UserDefaults.standard.string(forKey: "UserRole"),
                       let role = UserRole(rawValue: saved) {
                        self?.routeToHome(role: role)
                    } else {
                        let roleVC = RoleSelectionViewController(nibName: "RoleSelectionViewController", bundle: nil)
                        self?.navigationController?.pushViewController(roleVC, animated: true)
                    }

                case .failure(let error):
                    self?.presentAlert(title: "Login Failed", message: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Routing
    private func routeToHome(role: UserRole) {
        if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            switch role {
            case .organizer:
                scene.changeRootViewController(MainTabBarController())
            case .participant:
                scene.changeRootViewController(ParticipantMainTabBarController())
            }
        }
    }

    private func setRoot(_ vc: UIViewController) {
        if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            scene.changeRootViewController(vc)
        }
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
