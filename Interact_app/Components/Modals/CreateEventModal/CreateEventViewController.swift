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
//    @IBOutlet weak var teamSizeTextField: UITextField!
    @IBOutlet weak var minTeamSize: UITextField!
    
    @IBOutlet weak var maxTeamSize: UITextField!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var createButton: ButtonComponent!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var whatsappGrpLink: UITextField!
    
    @IBOutlet weak var eventTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var offlineDetailsStackView: UIStackView!
    @IBOutlet weak var onlineDetailsStackView: UIStackView!
    @IBOutlet weak var meetingLinkTextField: UITextField!
    @IBOutlet weak var rsvpSwitch: UISwitch!
    
    @IBOutlet weak var eligibilityCriteria: UITextView!
    @IBOutlet weak var prizePool: UITextView!
    @IBOutlet weak var eventCapacity: UITextField!
    
    // MARK: - Private State
        private var selectedImage: UIImage?
        private var datePicker: UIDatePicker?
        private weak var activeDateField: UITextField?

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupTextFields()
            setupEventTypeControl()
            setupImageUpload()
            setupKeyboardObservers()
            setupCreateButton()
            updateVisibility(animated: false)
        }

        // MARK: - UI Setup
        private func setupUI() {
            view.layer.cornerRadius = 16
            view.clipsToBounds = true
            scrollView.keyboardDismissMode = .interactive

            descriptionTextView.layer.cornerRadius = 10
            descriptionTextView.layer.borderWidth = 1
            descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
            
            eligibilityCriteria.layer.cornerRadius = 10
            eligibilityCriteria.layer.borderWidth = 1
            eligibilityCriteria.layer.borderColor = UIColor.systemGray4.cgColor
            
            prizePool.layer.cornerRadius = 10
            prizePool.layer.borderWidth = 1
            prizePool.layer.borderColor = UIColor.systemGray4.cgColor
        }

    private func setupTextFields() {
        let fields: [UITextField?] = [
            eventNameTextField,
            startDateTextField,
            endDateTextField,
            registrationDeadlineTextField,
            locationTextField,
            meetingLinkTextField,
            whatsappGrpLink,
            minTeamSize,
            maxTeamSize,
            eventCapacity
        ]
        
        fields.forEach { textField in
            guard let field = textField else { return }
            
            field.delegate = self
            
            // Fix: Set borderStyle to .none (not layer.borderStyle)
            field.borderStyle = .none
            field.layer.borderColor = UIColor.systemGray4.cgColor
            field.layer.borderWidth = 1
            field.layer.cornerRadius = 10
            
            // Fix: Use field.frame.height for dynamic padding
            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.height))
            field.leftView = leftPaddingView
            field.leftViewMode = .always
        }
        
        [startDateTextField, endDateTextField, registrationDeadlineTextField].forEach { dateField in
            dateField?.addTarget(self, action: #selector(dateFieldTapped(_:)), for: .editingDidBegin)
        }
    }

        private func setupCreateButton() {
            createButton.configure(title: "Create Event", backgroundColor: .systemBlue)
            createButton.onTap = { [weak self] in
                self?.createEventTapped()
            }
        }
    
    private func addDatePickerToolbar(to textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(donePressed)
        )

        let space = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )

        toolbar.setItems([space, doneButton], animated: false)
        textField.inputAccessoryView = toolbar
    }

    
    @objc private func donePressed() {
        if let picker = datePicker {
            dateChanged(picker)
        }
        view.endEditing(true)
    }


        // MARK: - Event Type Handling
        private func setupEventTypeControl() {
            eventTypeSegmentedControl.addTarget(
                self,
                action: #selector(eventTypeChanged(_:)),
                for: .valueChanged
            )
        }

        @objc private func eventTypeChanged(_ sender: UISegmentedControl) {
            updateVisibility(animated: true)
        }

        private func updateVisibility(animated: Bool) {
            let isOffline = eventTypeSegmentedControl.selectedSegmentIndex == 1
            let changes = {
                self.offlineDetailsStackView.isHidden = !isOffline
                self.onlineDetailsStackView.isHidden = isOffline
            }

            animated ? UIView.animate(withDuration: 0.25, animations: changes) : changes()
        }

        // MARK: - Image Upload
        private func setupImageUpload() {
            posterImageView.layer.cornerRadius = 12
            posterImageView.clipsToBounds = true
            posterImageView.backgroundColor = .systemGray6

            uploadImageButton.addTarget(
                self,
                action: #selector(uploadImageTapped),
                for: .touchUpInside
            )
        }

        @objc private func uploadImageTapped() {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true

            let alert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)

            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
                    picker.sourceType = .photoLibrary
                    self.present(picker, animated: true)
                })
            }

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            picker.dismiss(animated: true)
            let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
            selectedImage = image
            posterImageView.image = image
        }

        // MARK: - Create Event
        private func createEventTapped() {
            guard validateForm(),
                  let startDate = parseDate(from: startDateTextField.text),
                  let endDate = parseDate(from: endDateTextField.text),
                  let registrationDeadline = parseDate(from: registrationDeadlineTextField.text),
                  let minTeam = Int(minTeamSize.text ?? ""),
                  let maxTeam = Int(maxTeamSize.text ?? "") else {
                showAlert(title: "Invalid Input", message: "Please check all fields.")
                return
            }

            let locationType: EventLocationType =
                eventTypeSegmentedControl.selectedSegmentIndex == 1 ? .offline : .online

            let payload = EventCreatePayload(
                title: eventNameTextField.text!,
                description: descriptionTextView.text!,
                thumbnailUrl: "TEMP_IMAGE_URL", // replace later
                startDate: startDate,
                endDate: endDate,
                locationType: locationType,
                minTeamSize: minTeam,
                maxTeamSize: maxTeam,
                registrationDeadline: registrationDeadline,
                location: locationType != .online ? locationTextField.text : nil,
                meetingLink: locationType != .offline ? meetingLinkTextField.text : nil,
                rsvpForFoodRequired: locationType != .online ? rsvpSwitch.isOn : nil,
                externalLink: whatsappGrpLink.text,
                eligibilityCriteria: eligibilityCriteria.text!,
                prizePool: prizePool.text!,
                capacity: eventCapacity.text.flatMap(Int.init)
            )


            Task {
                do {
                    try await EventService.shared.createEvent(payload: payload)
                    showSuccessAlert()
                } catch {
                    showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }

        // MARK: - Validation
        private func validateForm() -> Bool {
            guard !(eventNameTextField.text?.isEmpty ?? true) else {
                showAlert(title: "Missing Info", message: "Event name required")
                return false
            }

            guard !(descriptionTextView.text?.isEmpty ?? true) else {
                showAlert(title: "Missing Info", message: "Description required")
                return false
            }

            return true
        }

        // MARK: - Date Picker
    @objc private func dateFieldTapped(_ sender: UITextField) {
        activeDateField = sender

        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.minimumDate = Date()
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)

        datePicker = picker
        sender.inputView = picker
        addDatePickerToolbar(to: sender)
    }


        @objc private func dateChanged(_ sender: UIDatePicker) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy - h:mm a"
            activeDateField?.text = formatter.string(from: sender.date)
        }

        private func parseDate(from text: String?) -> Date? {
            guard let text = text else { return nil }
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy - h:mm a"
            return formatter.date(from: text)
        }

        // MARK: - Alerts
        private func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }

        private func showSuccessAlert() {
            let alert = UIAlertController(
                title: "Success",
                message: "Event submitted for approval.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.dismiss(animated: true)
            })
            present(alert, animated: true)
        }

        // MARK: - Keyboard
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
            if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                scrollView.contentInset.bottom = frame.height + 20
            }
        }

        @objc private func keyboardWillHide(_ notification: Notification) {
            scrollView.contentInset.bottom = 0
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        @IBAction func closeButtonTapped(_ sender: UIButton) {
            dismiss(animated: true)
        }
    }
    

    // MARK: - UITextFieldDelegate
    extension CreateEventViewController: UITextFieldDelegate {
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if textField == startDateTextField ||
               textField == endDateTextField ||
               textField == registrationDeadlineTextField {
                return false
            }
            return true
        }

    }

    // MARK: - UITextViewDelegate
    extension CreateEventViewController: UITextViewDelegate {
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == UIColor.lightGray {
                textView.text = nil
                textView.textColor = UIColor.label
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = "Enter event description..."
                textView.textColor = UIColor.lightGray
            }
        }
}
