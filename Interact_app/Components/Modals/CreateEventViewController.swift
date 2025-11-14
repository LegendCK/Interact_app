//
//  CreateEventViewController.swift
//  Interact-UIKit
//
//  Created by admin73 on 12/11/25.
//


import UIKit

class CreateEventViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var registrationDeadlineTextField: UITextField!
    @IBOutlet weak var teamSizeTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var createButton: ButtonComponent!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var whatsappGrpLink: UITextField!
    
    private var datePicker: UIDatePicker?
    private weak var activeDateField: UITextField?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createButton.configure(
            title: "Create Event",
            backgroundColor: .systemBlue,
        )
        
        createButton.onTap = {
            print("Create Event Button tapped")
        }
        setupUI()
        setupTextFields()
        setupKeyboardObservers()
        setupImageUpload()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        scrollView.keyboardDismissMode = .interactive
        
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextView.layer.borderWidth = 1
        
        
        createButton.layer.cornerRadius = 10
    }
    
    private func setupTextFields() {
        let textFields = [
            eventNameTextField,
            startDateTextField,
            endDateTextField,
            locationTextField,
            registrationDeadlineTextField,
            whatsappGrpLink,
            teamSizeTextField
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
        
        // Add tap gesture for date fields
        [startDateTextField, endDateTextField, registrationDeadlineTextField].forEach { field in
            field?.addTarget(self, action: #selector(dateFieldTapped(_:)), for: .editingDidBegin)
        }
    }

    
    private func setupImageUpload() {
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.layer.cornerRadius = 12
        posterImageView.clipsToBounds = true
        
        uploadImageButton.layer.cornerRadius = 8
        uploadImageButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
//        uploadImageButton.setTitleColor(.white, for: .normal)
//        uploadImageButton.setTitle("Upload Image", for: .normal)
        
        uploadImageButton.addTarget(self, action: #selector(uploadImageTapped), for: .touchUpInside)
    }
   
    @objc private func uploadImageTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.mediaTypes = ["public.image"]
        picker.modalPresentationStyle = .fullScreen
        
        let alert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
        
        #if !targetEnvironment(simulator)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
                picker.sourceType = .camera
                self.present(picker, animated: true)
            }))
        }
        #endif
        
        // Choose from Library
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true)
            }))
        } else {
            let errorAlert = UIAlertController(
                title: "Photo Library Unavailable",
                message: "Please allow photo access from Settings.",
                preferredStyle: .alert
            )
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(errorAlert, animated: true)
            return
        }
     
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }

    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        // Use the edited image if available, else the original
        if let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            
            // ✅ If you want to enforce PNG/JPEG format:
            if let imageData = selectedImage.pngData() { // you can change to .jpegData(compressionQuality:)
                let convertedImage = UIImage(data: imageData)
                posterImageView.image = convertedImage
            } else {
                print("Unsupported image format")
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }


    // MARK: - Actions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    

    // MARK: - Date Picker
    @objc private func dateFieldTapped(_ sender: UITextField) {
        activeDateField = sender
        showDatePicker(for: sender)
    }

    private func showDatePicker(for textField: UITextField) {
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .dateAndTime
        datePicker?.preferredDatePickerStyle = .wheels
        datePicker?.minimumDate = Date()
        datePicker?.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        // Toolbar with Done button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneButton], animated: false)
        
        textField.inputAccessoryView = toolbar
        textField.inputView = datePicker
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy - h:mm a"
        activeDateField?.text = formatter.string(from: sender.date)
    }

    @objc private func donePressed() {
        if let picker = datePicker {
            dateChanged(picker)
        }
        view.endEditing(true)
    }
    
    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset.bottom = keyboardFrame.height + 20
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextFieldDelegate
extension CreateEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
