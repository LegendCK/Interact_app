//
//  OrgProfileSetupViewController.swift
//  Interact_app
//

//
//  OrgProfileSetupViewController.swift
//  Interact_app
//

import UIKit
import PhotosUI

class OrgProfileSetupViewController: UIViewController, UITextFieldDelegate {

    // Role passed from VerifyAccountViewController
    var userRole: UserRole?

    @IBOutlet weak var addLogo: UIImageView!
    @IBOutlet weak var addLogoButton: UIButton!
    @IBOutlet weak var saveButton: ButtonComponent!
    @IBOutlet weak var aboutOrgView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var orgTypeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var socialHandleTextField: UITextField!
    @IBOutlet weak var termsAndConditionCheckBoxButton: UIButton!
    
    @IBOutlet weak var usernameErrorLabel: UILabel!
    
    @IBOutlet weak var orgTypeErrorLabel: UILabel!
    
    @IBOutlet weak var locationErrorLabel: UILabel!
    
    @IBOutlet weak var socialHandleErrorLabel: UILabel!
    
    
    
    // MARK: - Error Labels
//        private let usernameErrorLabel = UILabel()
//        private let orgTypeErrorLabel = UILabel()
//        private let locationErrorLabel = UILabel()
//        private let socialHandleErrorLabel = UILabel()
        
    
    // Hide all error labels initially
//        usernameErrorLabel.isHidden = true;
//        orgTypeErrorLabel.isHidden = true;
//        locationErrorLabel.isHidden = true;
//        socialHandleErrorLabel.isHidden = true;
    
    
    
        // MARK: - Validation Properties
        private var isUsernameValid = false
        private var isOrgTypeValid = false
        private var isLocationValid = false
        private var isSocialHandleValid = true // Optional field
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Checkbox UI
            termsAndConditionCheckBoxButton.setImage(UIImage(systemName: "square"), for: .normal)
            termsAndConditionCheckBoxButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)

            configureUI()
            configureAddLogo()
            configureAddLogoButton()
            setupTextFields()
        }

        // MARK: - T&C Checkbox
        @IBAction func termsAndConditionCheckBoxTapped(_ sender: Any) {
            let termsVC = TermsAndConditionViewController(
                nibName: "TermsAndConditionViewController",
                bundle: nil
            )

            termsVC.onAccept = { [weak self] in
                guard let self else { return }
                
                self.termsAndConditionCheckBoxButton.isSelected = true
                self.validateAllFields()
            }

            termsVC.modalPresentationStyle = .pageSheet
            if let sheet = termsVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }

            present(termsVC, animated: true)
        }

        // MARK: - UI Setup
        private func configureUI() {
            aboutOrgView.layer.cornerRadius = 10
            aboutOrgView.layer.borderWidth = 1
            aboutOrgView.layer.borderColor = UIColor.systemGray4.cgColor
            
            saveButton.configure(title: "Save & Continue")
            setSaveButtonEnabled(false)
            
            saveButton.onTap = { [weak self] in
                guard let self else { return }
                
                // Validate all fields one final time
                if self.validateAllFields() {
                    self.completeSetup()
                }
            }
        }

        private func setSaveButtonEnabled(_ enabled: Bool) {
            saveButton.button.isEnabled = enabled
            saveButton.alpha = enabled ? 1.0 : 0.5
        }

        // MARK: - Logo Picker
        private func configureAddLogo() {
            addLogo.layer.cornerRadius = addLogo.frame.size.width / 2
            addLogo.clipsToBounds = true
            addLogo.contentMode = .scaleAspectFill
        }

        private func configureAddLogoButton() {
            addLogoButton.addTarget(self, action: #selector(addLogoTapped), for: .touchUpInside)
        }

        @objc private func addLogoTapped() {
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.selectionLimit = 1
            config.filter = .images

            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            present(picker, animated: true)
        }

        // MARK: - Text Field Setup
        private func setupTextFields() {
            let fields = [
                usernameTextField,
                orgTypeTextField,
                locationTextField,
                socialHandleTextField
            ]

            for field in fields {
                guard let f = field else { continue }
                f.delegate = self
                f.borderStyle = .none
                f.layer.borderColor = UIColor.systemGray4.cgColor
                f.layer.borderWidth = 1
                f.layer.cornerRadius = 10

                let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: f.frame.height))
                f.leftView = leftPadding
                f.leftViewMode = .always
                
                // Use editingDidEnd instead of editingChanged
                f.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
            }
            
            // Set specific keyboard types and placeholders
            usernameTextField.placeholder = "Choose a unique username"
            orgTypeTextField.placeholder = "Your organization type (e.g.,College Club)"
            locationTextField.placeholder = "Enter city of operation"
            socialHandleTextField.placeholder = "Add Instagram handle (optional)"
            
            // Add border to aboutOrgView (UITextView)
            aboutOrgView.layer.borderColor = UIColor.systemGray4.cgColor
            aboutOrgView.layer.borderWidth = 1
            aboutOrgView.layer.cornerRadius = 10
        }
        
    
        
        
        
        // MARK: - Text Field Validation
        @objc func textFieldDidEndEditing(_ textField: UITextField) {
            validateTextField(textField)
            validateAllFields()
        }
        
        // UITextFieldDelegate method for return key
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // Dismiss keyboard
            validateTextField(textField)
            validateAllFields()
            return true
        }
        
        private func validateTextField(_ textField: UITextField) {
            guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            
            switch textField {
            case usernameTextField:
                isUsernameValid = validateUsername(text)
                updateTextFieldAppearance(textField, isValid: isUsernameValid)
                updateErrorLabel(for: textField, isValid: isUsernameValid, message: "Organization name must be 3-50 characters and contain only letters, numbers, and spaces.")
                
            case orgTypeTextField:
                isOrgTypeValid = validateOrgType(text)
                updateTextFieldAppearance(textField, isValid: isOrgTypeValid)
                updateErrorLabel(for: textField, isValid: isOrgTypeValid, message: "Organization type must be 2-30 characters long.")
                
            case locationTextField:
                isLocationValid = validateLocation(text)
                updateTextFieldAppearance(textField, isValid: isLocationValid)
                updateErrorLabel(for: textField, isValid: isLocationValid, message: "Please use format: City, Country")
                
            case socialHandleTextField:
                isSocialHandleValid = validateSocialHandle(text)
                updateTextFieldAppearance(textField, isValid: isSocialHandleValid)
                updateErrorLabel(for: textField, isValid: isSocialHandleValid, message: "Social handle can only contain letters, numbers, underscores, and periods. Maximum 30 characters.")
                
            default:
                break
            }
        }
        
    private func updateErrorLabel(for textField: UITextField, isValid: Bool, message: String) {
        let errorLabel: UILabel?
        
        switch textField {
        case usernameTextField:
            errorLabel = usernameErrorLabel
        case orgTypeTextField:
            errorLabel = orgTypeErrorLabel
        case locationTextField:
            errorLabel = locationErrorLabel
        case socialHandleTextField:
            errorLabel = socialHandleErrorLabel
        default:
            errorLabel = nil
        }
        
        guard let errorLabel = errorLabel else { return }
        
        if isValid || textField.text?.isEmpty ?? true {
            errorLabel.isHidden = true
        } else {
            errorLabel.text = message
            errorLabel.isHidden = false
        }
    }
        
        private func validateUsername(_ username: String) -> Bool {
            if username.isEmpty {
                return false
            }
            
            if username.count < 3 {
                return false
            }
            
            if username.count > 50 {
                return false
            }
            
            // Allow letters, numbers, spaces, and basic punctuation
            let usernameRegex = "^[a-zA-Z0-9 ]+$"
            let isValid = NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluate(with: username)
            
            return isValid
        }
        
        private func validateOrgType(_ orgType: String) -> Bool {
            if orgType.isEmpty {
                return false
            }
            
            if orgType.count < 2 {
                return false
            }
            
            if orgType.count > 30 {
                return false
            }
            
            return true
        }
        
        private func validateLocation(_ location: String) -> Bool {
            if location.isEmpty {
                return false
            }
            
            if location.count < 2 {
                return false
            }
            
            // Basic location validation - should contain at least one comma for city, country format
            if !location.contains(",") {
                return false
            }
            
            return true
        }
        
        private func validateSocialHandle(_ socialHandle: String) -> Bool {
            // Social handle is optional, so empty is valid
            if socialHandle.isEmpty {
                return true
            }
            
            // Basic validation for social media handles
            // Allow letters, numbers, underscores, periods
            let socialHandleRegex = "^[a-zA-Z0-9_.]{1,30}$"
            let isValid = NSPredicate(format: "SELF MATCHES %@", socialHandleRegex).evaluate(with: socialHandle)
            
            return isValid
        }
        
        private func updateTextFieldAppearance(_ textField: UITextField, isValid: Bool) {
            UIView.animate(withDuration: 0.3) {
                if textField.text?.isEmpty ?? true {
                    textField.layer.borderColor = UIColor.systemGray4.cgColor
                } else {
                    textField.layer.borderColor = isValid ? UIColor.systemGray4.cgColor : UIColor.systemRed.cgColor
                }
                textField.layer.borderWidth = 2
            }
        }
        
        private func validateAllFields() -> Bool {
            let allFieldsValid = isUsernameValid && isOrgTypeValid && isLocationValid && isSocialHandleValid && termsAndConditionCheckBoxButton.isSelected
            
            setSaveButtonEnabled(allFieldsValid)
            return allFieldsValid
        }

        // MARK: - Final Save
        private func completeSetup() {
            guard let role = userRole else { return }

            // Save organization profile data
            saveOrganizationProfile()
            
            // Save role permanently
            UserDefaults.standard.set(role.rawValue, forKey: "UserRole")

            // Load correct home
            let homeVC: UIViewController =
                (role == .organizer)
                ? MainTabBarController()
                : ParticipantMainTabBarController()

            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.changeRootViewController(homeVC)
            }
        }
        
        private func saveOrganizationProfile() {
            // Save organization data to UserDefaults or CoreData
            let orgProfile: [String: Any] = [
                "username": usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                "orgType": orgTypeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                "location": locationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                "socialHandle": socialHandleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                "logoSet": addLogo.image != nil
            ]
            
            UserDefaults.standard.set(orgProfile, forKey: "OrganizationProfile")
            print("Organization profile saved successfully")
        }

        // MARK: - Alert Helper (keeping for other uses)
        private func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    // MARK: - PHPicker Delegate
    extension OrgProfileSetupViewController: PHPickerViewControllerDelegate {

        func picker(_ picker: PHPickerViewController,
                    didFinishPicking results: [PHPickerResult]) {

            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self)
            else { return }

            provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                guard let self = self,
                      let selectedImage = image as? UIImage else { return }

                DispatchQueue.main.async {
                    self.addLogo.image = selectedImage
                }
            }
        }
}
