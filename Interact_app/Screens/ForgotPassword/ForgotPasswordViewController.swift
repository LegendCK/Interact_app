//
//  ForgotPasswordViewController.swift
//  Interact_app
//

import UIKit

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backToLoginLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var sendResetLinkButton: ButtonComponent!
    
    // Auth manager
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
        
        setupUI()
        setupTextField()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backToLoginTapped))
        backToLoginLabel.isUserInteractionEnabled = true
        backToLoginLabel.addGestureRecognizer(tap)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        sendResetLinkButton.configure(title: "Send Reset Link")
        sendResetLinkButton.onTap = { [weak self] in
            self?.sendResetLink()
        }
        
        emailErrorLabel?.isHidden = true
    }
    
    private func setupTextField() {
        guard let emailTextField = emailTextField else { return }
        
        emailTextField.delegate = self
        emailTextField.borderStyle = .none
        emailTextField.layer.borderColor = UIColor.systemGray4.cgColor
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.cornerRadius = 10
        emailTextField.placeholder = "Enter your email"
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        emailTextField.leftView = padding
        emailTextField.leftViewMode = .always
        
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
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
    
    // MARK: - Validation
    @objc private func textFieldDidChange() {
        validateEmail(showError: false)
    }
    
    @discardableResult
    private func validateEmail(showError: Bool) -> Bool {
        guard let email = emailTextField.text, email.isValidEmail() else {
            if showError {
                emailErrorLabel?.text = "Please enter a valid email"
                emailErrorLabel?.isHidden = false
                emailTextField.layer.borderColor = UIColor.systemRed.cgColor
            }
            return false
        }
        
        emailErrorLabel?.isHidden = true
        emailTextField.layer.borderColor = UIColor.systemGray4.cgColor
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendResetLink()
        return true
    }
    
    // MARK: - Send Reset Link
    private func sendResetLink() {
        view.endEditing(true)
        
        guard validateEmail(showError: true) else { return }
        
        guard let auth = authManager else {
            presentAlert(title: "Error", message: "Auth manager not available")
            return
        }
        
        guard let email = emailTextField.text?.lowercased() else { return }
        
        sendResetLinkButton.button.isEnabled = false
        showLoading(true)
        
        auth.resetPassword(email: email) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.sendResetLinkButton.button.isEnabled = true
                self.showLoading(false)
                
                switch result {
                case .success():
                    print("Password reset email sent successfully")
                    self.showSuccessAlert(email: email)
                    
                case .failure(let error):
                    print("Password reset failed:", error)
                    self.presentAlert(
                        title: "Reset Failed",
                        message: "Unable to send reset link. Please check your email and try again."
                    )
                }
            }
        }
    }
    
    // MARK: - Success Alert
    private func showSuccessAlert(email: String) {
        let alert = UIAlertController(
            title: "Reset Link Sent",
            message: "We've sent a password reset link to \(email). Please check your inbox and follow the instructions.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Go back to login screen
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    @objc func backToLoginTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Alerts
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
