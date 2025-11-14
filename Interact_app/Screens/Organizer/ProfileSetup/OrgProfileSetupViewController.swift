//
//  OrgProfileSetupViewController.swift
//  Interact_app
//
//  Created by admin56 on 11/11/25.
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureAddLogo()
        configureAddLogoButton()
    }

    private func configureUI() {
        
        setupTextFields()
        aboutOrgView.layer.cornerRadius = 10
        aboutOrgView.layer.borderWidth = 1
        aboutOrgView.layer.borderColor = UIColor.systemGray4.cgColor
        saveButton.configure(title: "Save & Continue")
        saveButton.onTap = { [weak self] in
            guard let self = self else { return }

            let homeVC = TestHomeViewController(nibName: "TestHomeViewController", bundle: nil)
            self.navigationController?.setViewControllers([homeVC], animated: true)
        }
    }

    private func configureAddLogo() {
        // Make circular (you already set frame in storyboard)
        addLogo.layer.cornerRadius = addLogo.frame.size.width / 2
        addLogo.clipsToBounds = true
        addLogo.contentMode = .scaleAspectFill
    }

    private func configureAddLogoButton() {
        // Whatever styling you set in storyboard stays as is.
        // Just add action.
        addLogoButton.addTarget(self, action: #selector(addLogoTapped), for: .touchUpInside)
    }

    // MARK: - Image Picker
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
                // Set selected logo
                self.addLogo.image = selectedImage
                
                // ONLY CHANGE ICON → pencil
                //self.addLogoButton.setImage(UIImage(systemName: "pencil"), for: .normal)
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
                
                let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.height))
                field.leftView = leftPaddingView
                field.leftViewMode = .always
            }
        }
}

