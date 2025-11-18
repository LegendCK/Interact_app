//
//  SignupViewController.swift
//  Interact_app
//
//  Created by admin56 on 07/11/25.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var alreadyHaveAccLabel: UILabel!
    @IBOutlet weak var organizationNameTextField: UITextField!
    @IBOutlet weak var organizationEmailAddressTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var createPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var verifyEmailButton: ButtonComponent!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFields()
        
        verifyEmailButton.configure(title: "Verify Email")
        verifyEmailButton.onTap = {
            let verifyAccountVC = VerifyAccountViewController(nibName: "VerifyAccountViewController", bundle: nil)
            self.navigationController?.pushViewController(verifyAccountVC, animated: true)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backToLoginTapped))
        alreadyHaveAccLabel.isUserInteractionEnabled = true
        alreadyHaveAccLabel.addGestureRecognizer(tap)
    }

    @objc func backToLoginTapped() {
        goToLoginScreen()
    }
    
    // MARK: - Setup All Text Fields
    private func setupTextFields() {
        let textFields = [
            organizationNameTextField,
            organizationEmailAddressTextField,
            mobileNumberTextField,
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
            
            // Left padding
            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.height))
            field.leftView = leftPaddingView
            field.leftViewMode = .always
        }
        
        // Add password toggle buttons
        addPasswordToggle(to: createPasswordTextField)
        addPasswordToggle(to: confirmPasswordTextField)
    }
    
    
    // MARK: - Add Password Toggle Button
    private func addPasswordToggle(to textField: UITextField) {
        let eyeButton = UIButton(type: .system)

        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "eye.slash.fill")     // hidden state initially
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)

        // Padding so the icon isn't touching the border
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)

        eyeButton.configuration = config
        eyeButton.tintColor = .systemGray

        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)

        textField.rightView = eyeButton
        textField.rightViewMode = .always
        textField.isSecureTextEntry = true
    }

    
    // MARK: - Toggle Password Visibility
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        
        // Find the text field that owns this rightView button
        guard let textField = [createPasswordTextField, confirmPasswordTextField].first(where: {
            $0?.rightView == sender
        }) ?? nil else { return }

        guard var config = sender.configuration else { return }

        let wasFirstResponder = textField.isFirstResponder
        let selectedRange = textField.selectedTextRange

        // Toggle the secure text
        textField.isSecureTextEntry.toggle()

        // Fix cursor jump issue
        let currentText = textField.text
        textField.text = nil
        textField.text = currentText
        if let range = selectedRange { textField.selectedTextRange = range }
        if wasFirstResponder { textField.becomeFirstResponder() }

        // Update the eye icon
        let showingPassword = textField.isSecureTextEntry == false
        config.image = UIImage(systemName: showingPassword ? "eye.fill" : "eye.slash.fill")
        sender.configuration = config
    }

}
