//
//  OrgProfileSetupViewController.swift
//  Interact_app
//

import UIKit
import CoreLocation

class OrgProfileSetupViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Role
    var userRole: UserRole?

    // MARK: - Auth manager accessor
    var authManager: AuthManager? {
        if let scene = UIApplication.shared.connectedScenes.first,
           let delegate = scene.delegate as? SceneDelegate {
            return delegate.authManager
        }
        return nil
    }

    // MARK: - IBOutlets
    @IBOutlet weak var organizationNameTextField: UITextField!
    @IBOutlet weak var saveButton: ButtonComponent!
    @IBOutlet weak var aboutOrgView: UIView!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var orgTypeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var socialHandleTextField: UITextField!
    @IBOutlet weak var termsAndConditionCheckBoxButton: UIButton!
    @IBOutlet weak var orgNameErrorLabel: UILabel!
    @IBOutlet weak var orgPhoneNumberErrorLabel: UILabel!
    @IBOutlet weak var orgTypeErrorLabel: UILabel!
    @IBOutlet weak var locationErrorLabel: UILabel!
    @IBOutlet weak var socialHandleErrorLabel: UILabel!

    // MARK: - Dropdown Data
    private let orgTypes = [
        "Startup",
        "College / University",
        "Tech Community / Club",
        "Private Company",
        "Non-Profit / NGO",
        "Other"
    ]

    private var dropdownTableView: UITableView!
    private var isDropdownVisible = false

    // MARK: - Validation Flags
    private var isOrgNameValid = false
    private var isPhoneValid = false
    private var isOrgTypeValid = false
    private var isLocationValid = false
    private var isSocialHandleValid = true

    // MARK: - Location Manager
    private let locationManager = CLLocationManager()
    private var isRequestingLocation = false

    // MARK: - Activity Indicator
    private var spinner: UIActivityIndicatorView?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Checkbox appearance
        termsAndConditionCheckBoxButton.setImage(UIImage(systemName: "square"), for: .normal)
        termsAndConditionCheckBoxButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)

        configureUI()
        setupTextFields()
        setupDropdown()
        addArrowIcon()
        addLocationRightIcon()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    // MARK: - Checkbox
    @IBAction func termsAndConditionCheckBoxTapped(_ sender: Any) {
        let termsVC = TermsAndConditionViewController(
            nibName: "TermsAndConditionViewController",
            bundle: nil
        )

        termsVC.onAccept = { [weak self] in
            self?.termsAndConditionCheckBoxButton.isSelected = true
            self?.validateAllFields()
        }

        termsVC.modalPresentationStyle = .pageSheet
        if let sheet = termsVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

        present(termsVC, animated: true)
    }

    // MARK: - Setup UI
    private func configureUI() {
        aboutOrgView.layer.cornerRadius = 10
        aboutOrgView.layer.borderWidth = 1
        aboutOrgView.layer.borderColor = UIColor.systemGray4.cgColor

        saveButton.configure(title: "Save & Continue")
        setSaveButtonEnabled(false)

        saveButton.onTap = { [weak self] in
            guard let self else { return }
            if self.validateAllFields() {
                self.completeSetup()
            }
        }
    }

    private func setSaveButtonEnabled(_ enabled: Bool) {
        saveButton.button.isEnabled = enabled
        saveButton.alpha = enabled ? 1.0 : 0.5
    }

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

    // MARK: - TextField Setup
    private func setupTextFields() {
        let fields = [
            phoneNumberTextField,
            organizationNameTextField,
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

            f.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        }

        orgTypeTextField.placeholder = "Your organization type"
        locationTextField.placeholder = "Enter city of operation"
        socialHandleTextField.placeholder = "Instagram handle (optional)"
    }

    // MARK: - Org Type Arrow
    private func addArrowIcon() {
        let arrow = UIImageView(image: UIImage(systemName: "chevron.down"))
        arrow.tintColor = .gray
        arrow.contentMode = .scaleAspectFit

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))

        arrow.frame = CGRect(
            x: (40 - 20) / 2,
            y: (24 - 20) / 2,
            width: 20,
            height: 20
        )

        container.addSubview(arrow)
        orgTypeTextField.rightView = container
        orgTypeTextField.rightViewMode = .always

        // Disable keyboard
        orgTypeTextField.inputView = UIView()
    }

    // MARK: - Location Icon
    private func addLocationRightIcon() {
        let icon = UIImageView(image: UIImage(systemName: "location.fill"))
        icon.tintColor = .gray
        icon.contentMode = .scaleAspectFit

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))

        icon.frame = CGRect(
            x: (40 - 20) / 2,
            y: (24 - 20) / 2,
            width: 20,
            height: 20
        )

        container.addSubview(icon)

        locationTextField.rightView = container
        locationTextField.rightViewMode = .always

        // Disable keyboard, we auto-fill from location
        locationTextField.inputView = UIView()
    }

    // MARK: - Dropdown Menu
    private func setupDropdown() {
        dropdownTableView = UITableView()
        dropdownTableView.layer.cornerRadius = 8
        dropdownTableView.layer.borderWidth = 1
        dropdownTableView.layer.borderColor = UIColor.systemGray4.cgColor
        dropdownTableView.isHidden = true

        dropdownTableView.dataSource = self
        dropdownTableView.delegate = self
        dropdownTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        view.addSubview(dropdownTableView)
        dropdownTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dropdownTableView.topAnchor.constraint(equalTo: orgTypeTextField.bottomAnchor, constant: 4),
            dropdownTableView.leadingAnchor.constraint(equalTo: orgTypeTextField.leadingAnchor),
            dropdownTableView.trailingAnchor.constraint(equalTo: orgTypeTextField.trailingAnchor),
            dropdownTableView.heightAnchor.constraint(equalToConstant: 220)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleDropdown))
        orgTypeTextField.addGestureRecognizer(tap)
    }

    @objc private func toggleDropdown() {
        isDropdownVisible.toggle()
        dropdownTableView.isHidden = !isDropdownVisible

        // Rotate arrow
        if let container = orgTypeTextField.rightView,
           let arrow = container.subviews.first as? UIImageView {
            UIView.animate(withDuration: 0.25) {
                arrow.transform = self.isDropdownVisible
                    ? CGAffineTransform(rotationAngle: .pi)
                    : .identity
            }
        }
    }

    // MARK: - TextField Behaviors
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == orgTypeTextField {
            toggleDropdown()
            return false
        }
        if textField == locationTextField {
            requestUserLocation()
            return false
        }
        return true
    }

    @objc func textFieldDidEndEditing(_ textField: UITextField) {
        validateTextField(textField)
        validateAllFields()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        validateTextField(textField)
        validateAllFields()
        return true
    }

    // MARK: - Location Request
    private func requestUserLocation() {
        guard !isRequestingLocation else { return }
        isRequestingLocation = true

        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()

        case .denied, .restricted:
            showAlert(title: "Enable Location", message: "Please enable location in Settings.")
            isRequestingLocation = false

        @unknown default:
            isRequestingLocation = false
        }
    }

    // MARK: - Alert
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Validation Logic
    private func validateTextField(_ textField: UITextField) {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        switch textField {

        case organizationNameTextField:
            isOrgNameValid = validateOrgName(text)
            updateErrorLabel(label: orgNameErrorLabel, isValid: isOrgNameValid, message: "Enter a valid organization name.")

        case phoneNumberTextField:
            isPhoneValid = validatePhone(text)
            updateErrorLabel(label: orgPhoneNumberErrorLabel, isValid: isPhoneValid, message: "Enter a valid phone number.")

        case orgTypeTextField:
            isOrgTypeValid = validateOrgType(text)
            updateErrorLabel(label: orgTypeErrorLabel, isValid: isOrgTypeValid, message: "Select organization type.")

        case locationTextField:
            isLocationValid = validateLocation(text)
            updateErrorLabel(label: locationErrorLabel, isValid: isLocationValid, message: "Format: City, Country")

        case socialHandleTextField:
            isSocialHandleValid = validateSocialHandle(text)
            updateErrorLabel(label: socialHandleErrorLabel, isValid: isSocialHandleValid, message: "Invalid handle.")

        default: break
        }
    }

    private func updateErrorLabel(label: UILabel?, isValid: Bool, message: String) {
        guard let label else { return }
        if isValid || label.text!.isEmpty {
            label.isHidden = true
        } else {
            label.text = message
            label.isHidden = false
        }
    }

    // MARK: - Validators
    private func validateOrgName(_ text: String) -> Bool {
        return text.count >= 3
    }

    private func validatePhone(_ text: String) -> Bool {
        let regex = "^[0-9]{7,15}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: text)
    }

    private func validateOrgType(_ text: String) -> Bool {
        return !text.isEmpty
    }

    private func validateLocation(_ text: String) -> Bool {
        return text.contains(",") && text.count > 3
    }

    private func validateSocialHandle(_ text: String) -> Bool {
        if text.isEmpty { return true }
        let regex = "^[a-zA-Z0-9_.]{1,30}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: text)
    }

    private func validateAllFields() -> Bool {
        let valid =
            isOrgNameValid &&
            isPhoneValid &&
            isOrgTypeValid &&
            isLocationValid &&
            isSocialHandleValid &&
            termsAndConditionCheckBoxButton.isSelected

        setSaveButtonEnabled(valid)
        return valid
    }

    // MARK: - Final Save (networked)
    private func completeSetup() {
        guard let role = userRole else {
            showAlert(title: "Error", message: "User role not found.")
            return
        }

        guard let auth = authManager else {
            showAlert(title: "Error", message: "Auth manager unavailable.")
            return
        }

        // Disable UI and show spinner
        setSaveButtonEnabled(false)
        showLoading(true)

        // Fetch canonical user object (email) first
        auth.getUser { [weak self] userResult in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch userResult {
                case .success(let userObj):
                    let email = userObj["email"] as? String ?? ""
                    self.sendProfileCreateRequest(auth: auth, role: role, email: email)

                case .failure:
                    // Best-effort fallback: try decoding email from access token
                    if let token = auth.currentSession?.accessToken,
                       let emailFromToken = AuthManager.extractEmail(fromAccessToken: token),
                       !emailFromToken.isEmpty {
                        self.sendProfileCreateRequest(auth: auth, role: role, email: emailFromToken)
                    } else {
                        // Can't get email — show error and re-enable UI
                        self.showLoading(false)
                        self.setSaveButtonEnabled(true)
                        self.showAlert(title: "User Error", message: "Unable to fetch your account email. Please try signing out and signing in again.")
                    }
                }
            }
        }
    }

    // Helper to send profile payload
    private func sendProfileCreateRequest(auth: AuthManager, role: UserRole, email: String) {
        // Build payload matching profiles table columns
        // NO USERNAME - let database trigger generate it
        var payload: [String: Any] = [
            "email": email,
            "org_name": organizationNameTextField.text ?? "",
            "org_phone": phoneNumberTextField.text ?? "",
            "org_type": orgTypeTextField.text ?? "",
            "location": locationTextField.text ?? "",
            "social_handles": ["instagram": socialHandleTextField.text ?? ""], // JSONB field
            "role": role.rawValue
        ]

        auth.createProfile(payload: payload, maxRetries: 3) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.showLoading(false)
                self.setSaveButtonEnabled(true)

                switch result {
                case .success(let row):
                    print("Organization profile created successfully:", row)
                    
                    // Save role to UserDefaults
                    UserDefaults.standard.set(role.rawValue, forKey: "UserRole")

                    // Navigate to organizer home
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        sceneDelegate.routeToHome(role: role)
                    }


                case .failure(let error):
                    // Show server error
                    self.showAlert(title: "Profile Error", message: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - Dropdown TableView
extension OrgProfileSetupViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orgTypes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = orgTypes[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        orgTypeTextField.text = orgTypes[indexPath.row]

        validateTextField(orgTypeTextField)
        validateAllFields()

        dropdownTableView.isHidden = true
        isDropdownVisible = false

        // Reset arrow rotation
        if let container = orgTypeTextField.rightView,
           let arrow = container.subviews.first as? UIImageView {
            UIView.animate(withDuration: 0.25) {
                arrow.transform = .identity
            }
        }
    }
}

// MARK: - Location Manager
extension OrgProfileSetupViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let loc = locations.first else { return }
        locationManager.stopUpdatingLocation()

        CLGeocoder().reverseGeocodeLocation(loc) { [weak self] placemarks, _ in
            guard let self else { return }
            if let place = placemarks?.first {
                let city = place.locality ?? ""
                let country = place.country ?? ""

                self.locationTextField.text = "\(city), \(country)"
                self.validateTextField(self.locationTextField)
                self.validateAllFields()
            }
            self.isRequestingLocation = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isRequestingLocation = false
        showAlert(title: "Location Error", message: "Unable to fetch location.")
    }
}
