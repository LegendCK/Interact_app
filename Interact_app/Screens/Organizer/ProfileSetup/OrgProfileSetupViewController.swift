//
//  OrgProfileSetupViewController.swift
//  Interact_app
//

import UIKit
import PhotosUI

class OrgProfileSetupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var addLogo: UIImageView!
    @IBOutlet weak var addLogoButton: UIButton!
    @IBOutlet weak var saveButton: ButtonComponent!
    @IBOutlet weak var aboutOrgView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var orgTypeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var socialHandleTextField: UITextField!
    @IBOutlet weak var termsAndConditionCheckBoxButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Checkbox UI
        termsAndConditionCheckBoxButton.setImage(UIImage(systemName: "square"), for: .normal)
        termsAndConditionCheckBoxButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)

        configureUI()
        configureAddLogo()
        configureAddLogoButton()
    }

    @IBAction func termsAndConditionCheckBoxTapped(_ sender: Any) {

        let termsVC = TermsAndConditionViewController(
            nibName: "TermsAndConditionViewController",
            bundle: nil
        )

        // Callback after Accept
        termsVC.onAccept = { [weak self] in
            guard let self else { return }
            
            // Tick checkbox
            self.termsAndConditionCheckBoxButton.isSelected = true
            
            // Enable save button
            self.setSaveButtonEnabled(true)
        }

        termsVC.modalPresentationStyle = .pageSheet

        if let sheet = termsVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

        present(termsVC, animated: true)
    }

    private func configureUI() {
        
        setupTextFields()
        
        aboutOrgView.layer.cornerRadius = 10
        aboutOrgView.layer.borderWidth = 1
        aboutOrgView.layer.borderColor = UIColor.systemGray4.cgColor
        
        saveButton.configure(title: "Save & Continue")

        // Disable save button until T&C accepted
        setSaveButtonEnabled(false)

        saveButton.onTap = { [weak self] in
            guard self != nil else { return }
            
            let tabBar = MainTabBarController()
            
            if let sceneDelegate = UIApplication.shared.connectedScenes
                .first?.delegate as? SceneDelegate {
                sceneDelegate.changeRootViewController(tabBar)
            }
        }
    }

    private func setSaveButtonEnabled(_ enabled: Bool) {
        saveButton.button.isEnabled = enabled
        saveButton.alpha = enabled ? 1.0 : 0.5
    }

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
}

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
    
    private func setupTextFields() {
        let textFields = [
            usernameTextField,
            orgTypeTextField,
            locationTextField,
            socialHandleTextField
        ]
        
        for textField in textFields {
            guard let field = textField else { continue }
            field.delegate = self
            
            field.borderStyle = .none
            field.layer.borderColor = UIColor.systemGray4.cgColor
            field.layer.borderWidth = 1
            field.layer.cornerRadius = 10
            
            let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.height))
            field.leftView = leftPadding
            field.leftViewMode = .always
        }
    }
}
