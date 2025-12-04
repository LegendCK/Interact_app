import UIKit

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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPasswordToggle()
        setupButtons()
        setupMainTitle()
        setupSignUpLabel()
        setupTextFields()
    }
    
    private func setupPasswordToggle() {
        let eyeButton = UIButton(type: .system)

        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "eye.slash.fill")     // initial image (hidden)
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)

        // Add internal padding so the icon is not touching the border
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)

        eyeButton.configuration = config
        eyeButton.tintColor = .systemGray

        // Action
        eyeButton.addTarget(self, action: #selector(didTapToggleEye(_:)), for: .touchUpInside)

        // Assign to text field
        passwordTextField.rightView = eyeButton
        passwordTextField.rightViewMode = .always

        passwordTextField.isSecureTextEntry = true
    }


    @objc private func didTapToggleEye(_ sender: UIButton) {
        guard var config = sender.configuration else { return }

        let isShowingPassword = passwordTextField.isSecureTextEntry == false

        // Toggle secure entry
        let wasFirstResponder = passwordTextField.isFirstResponder
        let selectedRange = passwordTextField.selectedTextRange

        passwordTextField.isSecureTextEntry.toggle()

        // Avoid cursor jump
        let currentText = passwordTextField.text
        passwordTextField.text = nil
        passwordTextField.text = currentText
        if let range = selectedRange { passwordTextField.selectedTextRange = range }
        if wasFirstResponder { passwordTextField.becomeFirstResponder() }

        // Swap image
        config.image = UIImage(
            systemName: isShowingPassword ? "eye.slash.fill" : "eye.fill"
        )
        sender.configuration = config
    }

    
    @IBAction func forgetPasswordOnTap(_ sender: Any) {
        let forgotPasswordVC = ForgotPasswordViewController(nibName: "ForgotPasswordViewController", bundle: nil)
        navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }
    

    private func setupButtons() {
        loginButton.configure(
            title: "Login",
            backgroundColor: .systemBlue
        )

        loginButton.onTap = { [weak self] in
            self?.loginTapped()
        }

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
    }

    private func setupTextFields() {
        emailAddressErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true

        setupNormalState(for: emailAddressTextField)
        setupNormalState(for: passwordTextField)

        passwordTextField.isSecureTextEntry = true

        emailAddressTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        let textFields = [
            emailAddressTextField,
            passwordTextField,
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
    }

    private func setupNormalState(for textField: UITextField) {
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
    }

    private func setupErrorState(for textField: UITextField) {
        textField.layer.borderColor = UIColor.systemRed.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
    }

    // MARK: - Live Validation
    @objc private func textFieldDidChange() {
        validateInputs(showErrors: false)
    }

    @discardableResult
    private func validateInputs(showErrors: Bool) -> Bool {
        var isValid = true

        // Validate Email
        if let email = emailAddressTextField.text, email.isValidEmail() {
            emailAddressErrorLabel.isHidden = true
            setupNormalState(for: emailAddressTextField)
        } else {
            isValid = false
            if showErrors {
                emailAddressErrorLabel.text = "Please enter a valid email address"
                emailAddressErrorLabel.isHidden = false
                setupErrorState(for: emailAddressTextField)
            }
        }

        // Validate Password
        if let password = passwordTextField.text, password.count >= 6 {
            passwordErrorLabel.isHidden = true
            setupNormalState(for: passwordTextField)
        } else {
            isValid = false
            if showErrors {
                passwordErrorLabel.text = "Password must be at least 6 characters"
                passwordErrorLabel.isHidden = false
                setupErrorState(for: passwordTextField)
            }
        }

        return isValid
    }

    // MARK: - Login Action
    private func loginTapped() {
        view.endEditing(true)

        if !validateInputs(showErrors: true) {
//            shakeAnimation()
            return
        }

        print("Login button tapped — Valid Input")

        let email = emailAddressTextField.text?.lowercased() ?? ""

        // ORGANIZER
        if email == "organizer@gmail.com" {
            UserDefaults.standard.set(UserRole.organizer.rawValue, forKey: "UserRole")

            let organizerTab = MainTabBarController()
            setRoot(organizerTab)

        // PARTICIPANT
        } else if email == "participant@gmail.com" {
            UserDefaults.standard.set(UserRole.participant.rawValue, forKey: "UserRole")

            let participantTab = ParticipantMainTabBarController()
            setRoot(participantTab)

        } else {
            emailAddressErrorLabel.text = "Account not found"
            emailAddressErrorLabel.isHidden = false
            setupErrorState(for: emailAddressTextField)
        }

    }

    private func setRoot(_ vc: UIViewController) {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(vc)
        }
    }


    // MARK: - Shake Animation
//    private func shakeAnimation() {
//        let animation = CABasicAnimation(keyPath: "position")
//        animation.duration = 0.05
//        animation.repeatCount = 3
//        animation.autoreverses = true
//        animation.fromValue = CGPoint(x: view.center.x - 8, y: view.center.y)
//        animation.toValue = CGPoint(x: view.center.x + 8, y: view.center.y)
//        view.layer.add(animation, forKey: "position")
//    }

    private func setupMainTitle() {
        let fullText = "Log in to Interact"
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

    private func setupSignUpLabel() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(signUpTapped))
        signUpLabel.isUserInteractionEnabled = true
        signUpLabel.addGestureRecognizer(tap)
    }

    @objc private func signUpTapped() {
        print("Sign Up tapped!")
        let roleVC = RoleSelectionViewController(nibName: "RoleSelectionViewController", bundle: nil)
        navigationController?.pushViewController(roleVC, animated: true)
    }
}

extension String {
    func isValidEmail() -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
}
