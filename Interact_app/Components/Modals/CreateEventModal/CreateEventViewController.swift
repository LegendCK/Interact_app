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
    
    @IBOutlet weak var eventTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var offlineDetailsStackView: UIStackView!
    
    @IBOutlet weak var rsvpSwitch: UISwitch!
    
    
    private var datePicker: UIDatePicker?
        private weak var activeDateField: UITextField?
        private var selectedImage: UIImage?

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupCreateButton()
            setupUI()
            setupTextFields()
            setupKeyboardObservers()
            setupImageUpload()
            
            // Setup event type control and initial visibility for offline details
            setupEventTypeControl()
            updateOfflineVisibility(animated: false)
        }
        
        // MARK: - Button Setup
        private func setupCreateButton() {
            createButton.configure(
                title: "Create Event",
                backgroundColor: .systemBlue
            )
            
            createButton.onTap = { [weak self] in
                self?.createEventTapped()
            }
        }
        
        // MARK: - UI Setup
        private func setupUI() {
            view.layer.cornerRadius = 16
            view.clipsToBounds = true
            scrollView.keyboardDismissMode = .interactive
            
            descriptionTextView.layer.cornerRadius = 10
            descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
            descriptionTextView.layer.borderWidth = 1
            descriptionTextView.textColor = UIColor.black
            
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
            posterImageView.backgroundColor = .systemGray6
            
            uploadImageButton.layer.cornerRadius = 8
            uploadImageButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
            uploadImageButton.addTarget(self, action: #selector(uploadImageTapped), for: .touchUpInside)
        }
       
        // MARK: - Image Picker
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
            
            if let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                self.selectedImage = selectedImage
                posterImageView.image = selectedImage
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }

        // MARK: - Event Creation
        private func createEventTapped() {
            guard validateForm() else { return }
            
            // Convert date strings to Date objects
            guard let startDate = convertToDate(from: startDateTextField.text),
                  let endDate = convertToDate(from: endDateTextField.text),
                  let registrationDeadline = convertToDate(from: registrationDeadlineTextField.text) else {
                showAlert(title: "Invalid Date", message: "Please check your date formats")
                return
            }
            
            // Validate date logic
            if !validateDates(startDate: startDate, endDate: endDate, registrationDeadline: registrationDeadline) {
                return
            }
            
            // Save to Core Data
            // NOTE: Added rsvpForFood parameter at end; pass true if offline AND switch is on, else false
            let isOffline = (eventTypeSegmentedControl.selectedSegmentIndex == 1)
            let rsvpForFoodValue = isOffline ? rsvpSwitch.isOn : false
            
            let success = CoreDataManager.shared.createEvent(
                eventName: eventNameTextField.text ?? "",
                startDate: startDate,
                endDate: endDate,
                location: isOffline ? (locationTextField.text ?? "") : "Online Event",
                registrationDeadline: registrationDeadline,
                teamSize: teamSizeTextField.text ?? "",
                eventDescription: descriptionTextView.text,
                whatsappGroupLink: whatsappGrpLink.text,
                posterImage: selectedImage,
                eventType: isOffline ? "Offline" : "Online",
                rsvpForFood: rsvpForFoodValue
            )
            
            if success {
                showSuccessAlert()
                debugAfterSave()
            } else {
                showAlert(title: "Error", message: "Failed to save event. Please try again.")
            }
        }
        
        // MARK: - Validation
    private func validateForm() -> Bool {
        let isOffline = (eventTypeSegmentedControl.selectedSegmentIndex == 1)
        
        guard !(eventNameTextField.text?.isEmpty ?? true) else {
            showAlert(title: "Missing Information", message: "Please enter event name")
            return false
        }
        
        guard !(startDateTextField.text?.isEmpty ?? true) else {
            showAlert(title: "Missing Information", message: "Please select start date")
            return false
        }
        
        guard !(endDateTextField.text?.isEmpty ?? true) else {
            showAlert(title: "Missing Information", message: "Please select end date")
            return false
        }
        
        // Location required only if offline
        if isOffline {
            guard !(locationTextField.text?.isEmpty ?? true) else {
                showAlert(title: "Missing Information", message: "Please enter location")
                return false
            }
        }
        
        guard !(registrationDeadlineTextField.text?.isEmpty ?? true) else {
            showAlert(title: "Missing Information", message: "Please select registration deadline")
            return false
        }
        
        // Team Size validation - must be a number
        if let teamSizeText = teamSizeTextField.text, !teamSizeText.isEmpty {
            let numericCharacterSet = CharacterSet.decimalDigits
            let inputCharacterSet = CharacterSet(charactersIn: teamSizeText)
            
            guard numericCharacterSet.isSuperset(of: inputCharacterSet) else {
                showAlert(title: "Invalid Team Size", message: "Team size must be a number")
                return false
            }
            
            // Optional: Validate team size is at least 1
            if let teamSize = Int(teamSizeText), teamSize < 1 {
                showAlert(title: "Invalid Team Size", message: "Team size must be at least 1")
                return false
            }
        }
        
        // Description validation - must not be empty or placeholder text
        let descriptionText = descriptionTextView.text ?? ""
        let isPlaceholderText = descriptionText == "Enter event description..." || descriptionText.isEmpty
        let hasValidDescription = !isPlaceholderText && !descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        guard hasValidDescription else {
            showAlert(title: "Missing Information", message: "Please enter event description")
            return false
        }
        
        // WhatsApp link is optional - no validation needed
        
        return true
    }
        
        private func validateDates(startDate: Date, endDate: Date, registrationDeadline: Date) -> Bool {
            // Registration deadline should be before start date
            if registrationDeadline >= startDate {
                showAlert(title: "Invalid Dates", message: "Registration deadline must be before the event start date")
                return false
            }
            
            // End date should be after start date
            if endDate <= startDate {
                showAlert(title: "Invalid Dates", message: "End date must be after start date")
                return false
            }
            
            // Registration deadline shouldn't be in the past
            if registrationDeadline < Date() {
                showAlert(title: "Invalid Dates", message: "Registration deadline cannot be in the past")
                return false
            }
            
            return true
        }
        
        private func convertToDate(from string: String?) -> Date? {
            guard let string = string else { return nil }
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy - h:mm a"
            return formatter.date(from: string)
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

        // MARK: - Event Type Control (Offline/Online) Handling
        private func setupEventTypeControl() {
            // If the segmented control wasn't configured in IB, make sure it exists.
            eventTypeSegmentedControl.addTarget(self, action: #selector(eventTypeChanged(_:)), for: .valueChanged)
        }
        
        @objc private func eventTypeChanged(_ sender: UISegmentedControl) {
            updateOfflineVisibility(animated: true)
        }
        
        private func updateOfflineVisibility(animated: Bool) {
            let isOffline = (eventTypeSegmentedControl.selectedSegmentIndex == 1)
            
            let changes = {
                self.offlineDetailsStackView.isHidden = !isOffline
                self.offlineDetailsStackView.alpha = isOffline ? 1.0 : 0.0
            }
            
            if animated {
                UIView.animate(withDuration: 0.25, animations: {
                    changes()
                    self.view.layoutIfNeeded()
                })
            } else {
                changes()
            }
        }
        
        // MARK: - Debug Methods
        private func printAllEvents() {
            let events = CoreDataManager.shared.fetchAllEvents()
            print("=== CORE DATA EVENTS DUMP ===")
            print("Total events: \(events.count)")
            
            for (index, event) in events.enumerated() {
                print("""
                Event #\(index + 1):
                - ID: \(event.id?.uuidString ?? "N/A")
                - Name: \(event.eventName ?? "N/A")
                - Start: \(event.startDate?.description ?? "N/A")
                - End: \(event.endDate?.description ?? "N/A")
                - Location: \(event.location ?? "N/A")
                - Team Size: \(event.teamSize)
                - WhatsApp: \(event.whatsappGroupLink ?? "N/A")
                - Description: \(event.eventDescription ?? "N/A")
                - Created: \(event.createdAt?.description ?? "N/A")
                - Event Type: \(event.eventType)
                - RSVP For Food Required: \(event.rsvpForFood)
                ---
                """)
            }
        }

        // Call this after saving to verify
        private func debugAfterSave() {
            print("🔄 Checking saved data...")
            printAllEvents()
        }
            
        // MARK: - Alert Methods
        private func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        
        private func showSuccessAlert() {
            let alert = UIAlertController(
                title: "Success!",
                message: "Event created successfully!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.dismiss(animated: true)
            })
            present(alert, animated: true)
        }
        
        // MARK: - Actions
        @IBAction func closeButtonTapped(_ sender: UIButton) {
            dismiss(animated: true)
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
