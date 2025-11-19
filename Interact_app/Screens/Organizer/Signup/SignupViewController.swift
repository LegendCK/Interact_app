//
//  SignupViewController.swift
//  Interact_app
//
//  Created by admin56 on 07/11/25.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {

    // Role passed from RoleSelectionViewController
    var userRole: UserRole?

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
        verifyEmailButton.onTap = { [weak self] in
            guard let self else { return }

            let verifyVC = VerifyAccountViewController(
                nibName: "VerifyAccountViewController",
                bundle: nil
            )
            verifyVC.userRole = self.userRole   // ⬅ IMPORTANT
            self.navigationController?.pushViewController(verifyVC, animated: true)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(backToLoginTapped))
        alreadyHaveAccLabel.isUserInteractionEnabled = true
        alreadyHaveAccLabel.addGestureRecognizer(tap)
    }

    @objc func backToLoginTapped() {
        goToLoginScreen()
    }

    // MARK: - Text Fields Setup
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

            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.height))
            field.leftView = leftPaddingView
            field.leftViewMode = .always
        }

        addPasswordToggle(to: createPasswordTextField)
        addPasswordToggle(to: confirmPasswordTextField)
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
}
