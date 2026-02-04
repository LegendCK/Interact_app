import UIKit
import CoreLocation
import PhotosUI

final class EditParticipantProfileModalViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var profileImageContainer: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!

    @IBOutlet weak var primaryRoleTextField: UITextField!
    @IBOutlet weak var secondaryRoleTextField: UITextField!
    @IBOutlet weak var academicYearTextField: UITextField!
    @IBOutlet weak var collegeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!

    @IBOutlet weak var primaryRoleErrorLabel: UILabel!
    @IBOutlet weak var secondaryRoleErrorLabel: UILabel!
    @IBOutlet weak var academicYearErrorLabel: UILabel!
    @IBOutlet weak var collegeErrorLabel: UILabel!
    @IBOutlet weak var locationErrorLabel: UILabel!

    // MARK: - Dependencies
    var profile: ParticipantProfile? // Passed from parent
    var onSave: (() -> Void)? // Callback to refresh profile
    weak var viewModel: ParticipantProfileViewModel? // To call update methods

    // MARK: - Dropdown Data
    private let roles = [
        "Frontend Developer","Backend Developer","Full Stack Developer",
        "Mobile App Developer","AI Engineer","Machine Learning Engineer",
        "Cybersecurity Specialist","IoT Developer","Embedded Systems Engineer",
        "Robotics Engineer","UI/UX Designer","Graphic Designer",
        "Project Manager","Pitch Presenter"
    ]

    private let academicYears = [
        "1st Year","2nd Year","3rd Year",
        "4th Year","5th Year","Alumni"
    ]

    private let colleges = [
        "Amity University, Mumbai","Amity University, Noida",
        "BITS Pilani","BITS Goa","BITS Hyderabad",
        "IIT Bombay","IIT Delhi","IIT Madras",
        "NIT Trichy","VIT Vellore","VIT Chennai",
        "SRM Institute of Science and Technology",
        "Manipal Institute of Technology",
        "Lovely Professional University",
        "Graphic Era University","Other"
    ]

    // MARK: - Location
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    // MARK: - Change Detection
    private var originalState: ProfileState!
    private var hasChanges = false {
        didSet {
            navigationItem.rightBarButtonItem?.isEnabled = hasChanges
        }
    }
    
    private var newPhotoData: Data? // Store new photo if selected

    private struct ProfileState: Equatable {
        let imageData: Data?
        let primaryRole: String?
        let secondaryRole: String?
        let academicYear: String?
        let college: String?
        let location: String?
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupUI()
        setupTextFields()
        setupImagePicker()
        hideAllErrors()
        prefillData()
        captureOriginalState()
    }

    // MARK: - Setup
    private func setupNavigation() {
        title = "Edit Profile"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )

        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    private func setupUI() {
        profileImageContainer.layer.cornerRadius = 14
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
        profileImage.clipsToBounds = true

        [
            primaryRoleErrorLabel,
            secondaryRoleErrorLabel,
            academicYearErrorLabel,
            collegeErrorLabel,
            locationErrorLabel
        ].forEach {
            $0?.font = .systemFont(ofSize: 12)
            $0?.textColor = .systemRed
            $0?.text = nil
        }
    }

    private func setupTextFields() {
        let fields = [
            primaryRoleTextField,
            secondaryRoleTextField,
            academicYearTextField,
            collegeTextField,
            locationTextField
        ]

        fields.forEach {
            $0?.delegate = self
            $0?.inputView = UIView() // disables keyboard
        }
    }

    private func setupImagePicker() {
        addPhotoButton.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
    }

    private func hideAllErrors() {
        primaryRoleErrorLabel.text = nil
        secondaryRoleErrorLabel.text = nil
        academicYearErrorLabel.text = nil
        collegeErrorLabel.text = nil
        locationErrorLabel.text = nil
    }
    
    // MARK: - Prefill Data
    private func prefillData() {
        guard let profile = profile else { return }
        
        primaryRoleTextField.text = profile.primaryRole
        secondaryRoleTextField.text = profile.secondaryRole
        academicYearTextField.text = profile.academicYear
        collegeTextField.text = profile.college
        locationTextField.text = profile.location
        
        // Load avatar if available
        if let avatarUrl = profile.avatarUrl, let url = URL(string: avatarUrl) {
            loadImage(from: url)
        }
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.profileImage.image = image
            }
        }.resume()
    }

    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        hideAllErrors()

        var valid = true

        if primaryRoleTextField.text?.isEmpty == true {
            primaryRoleErrorLabel.text = "Primary role is required"
            valid = false
        }

        if academicYearTextField.text?.isEmpty == true {
            academicYearErrorLabel.text = "Academic year is required"
            valid = false
        }

        if collegeTextField.text?.isEmpty == true {
            collegeErrorLabel.text = "College is required"
            valid = false
        }

        if locationTextField.text?.isEmpty == true {
            locationErrorLabel.text = "Location is required"
            valid = false
        }

        guard valid else { return }
        
        // Show loading
        let loadingAlert = UIAlertController(title: "Saving...", message: nil, preferredStyle: .alert)
        present(loadingAlert, animated: true)

        // Step 1: Upload photo if changed
        if let photoData = newPhotoData {
            uploadPhotoThenSave(photoData: photoData, loadingAlert: loadingAlert)
        } else {
            saveProfileData(avatarUrl: nil, loadingAlert: loadingAlert)
        }
    }
    
    private func uploadPhotoThenSave(photoData: Data, loadingAlert: UIAlertController) {
        viewModel?.uploadProfilePhoto(imageData: photoData) { [weak self] url in
            guard let self = self else { return }
            
            if let url = url {
                self.saveProfileData(avatarUrl: url, loadingAlert: loadingAlert)
            } else {
                loadingAlert.dismiss(animated: true) {
                    self.showError("Failed to upload photo")
                }
            }
        }
    }
    
    private func saveProfileData(avatarUrl: String?, loadingAlert: UIAlertController) {
        var fields: [String: Any] = [
            "primary_role": primaryRoleTextField.text ?? "",
            "academic_year": academicYearTextField.text ?? "",
            "college": collegeTextField.text ?? "",
            "location": locationTextField.text ?? ""
        ]
        
        if let secondary = secondaryRoleTextField.text, !secondary.isEmpty {
            fields["secondary_role"] = secondary
        }
        
        if let avatarUrl = avatarUrl {
            fields["avatar_url"] = avatarUrl
        }
        
        viewModel?.updateProfile(fields: fields) { [weak self] success in
            loadingAlert.dismiss(animated: true) {
                if success {
                    self?.onSave?()
                    self?.dismiss(animated: true)
                } else {
                    self?.showError("Failed to save profile")
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Image Picker
    @objc private func changePhotoTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - Location
    private func requestLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    // MARK: - Sheets
    private func showSheet(
        title: String,
        options: [String],
        onSelect: @escaping (String) -> Void
    ) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)

        options.forEach { option in
            alert.addAction(
                UIAlertAction(title: option, style: .default) { _ in
                    onSelect(option)
                }
            )
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Change Tracking
    private func captureOriginalState() {
        originalState = currentState()
    }

    private func currentState() -> ProfileState {
        ProfileState(
            imageData: newPhotoData ?? profileImage.image?.jpegData(compressionQuality: 0.8),
            primaryRole: primaryRoleTextField.text,
            secondaryRole: secondaryRoleTextField.text,
            academicYear: academicYearTextField.text,
            college: collegeTextField.text,
            location: locationTextField.text
        )
    }

    private func detectChanges() {
        hasChanges = currentState() != originalState
    }
}

// MARK: - UITextFieldDelegate
extension EditParticipantProfileModalViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        switch textField {

        case primaryRoleTextField:
            showSheet(title: "Primary Role", options: roles) { [weak self] value in
                self?.primaryRoleTextField.text = value
                if self?.secondaryRoleTextField.text == value {
                    self?.secondaryRoleTextField.text = nil
                }
                self?.detectChanges()
            }

        case secondaryRoleTextField:
            let filtered = roles.filter { $0 != primaryRoleTextField.text }
            showSheet(title: "Secondary Role", options: filtered) { [weak self] value in
                self?.secondaryRoleTextField.text = value
                self?.detectChanges()
            }

        case academicYearTextField:
            showSheet(title: "Academic Year", options: academicYears) { [weak self] value in
                self?.academicYearTextField.text = value
                self?.detectChanges()
            }

        case collegeTextField:
            showSheet(title: "College", options: colleges) { [weak self] value in
                self?.collegeTextField.text = value
                self?.detectChanges()
            }

        case locationTextField:
            requestLocation()

        default:
            break
        }

        return false
    }
}

// MARK: - PHPicker Delegate
extension EditParticipantProfileModalViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            guard let image = image as? UIImage else { return }
            
            DispatchQueue.main.async {
                self?.profileImage.image = image
                // Compress to JPEG for upload
                self?.newPhotoData = image.jpegData(compressionQuality: 0.8)
                self?.detectChanges()
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension EditParticipantProfileModalViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }

        geocoder.reverseGeocodeLocation(loc) { [weak self] placemarks, _ in
            guard let place = placemarks?.first else { return }

            let city = place.locality ?? ""
            let country = place.country ?? ""
            self?.locationTextField.text = "\(city), \(country)"
            self?.detectChanges()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationErrorLabel.text = "Unable to detect location"
    }
}
