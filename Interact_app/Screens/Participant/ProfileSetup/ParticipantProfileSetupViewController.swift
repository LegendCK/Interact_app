//
//  ParticipantProfileSetupViewController.swift
//  Interact_app
//

import UIKit
import CoreLocation

class ParticipantProfileSetupViewController: UIViewController, UITextFieldDelegate {

    var userRole: UserRole?
    
    // MARK: - Auth Manager
    var authManager: AuthManager? {
        if let scene = UIApplication.shared.connectedScenes.first,
           let delegate = scene.delegate as? SceneDelegate {
            return delegate.authManager
        }
        return nil
    }

    // MARK: - IBOutlets
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var middleNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var rolesTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var academicYearTextField: UITextField!
    @IBOutlet weak var collegeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!

    @IBOutlet weak var firstNameErrorLabel: UILabel!
    @IBOutlet weak var middleNameErrorLabel: UILabel!
    @IBOutlet weak var lastNameErrorLabel: UILabel!
    @IBOutlet weak var rolesErrorLabel: UILabel!
    @IBOutlet weak var genderErrorLabel: UILabel!
    @IBOutlet weak var academicYearErrorLabel: UILabel!
    @IBOutlet weak var collegeErrorLabel: UILabel!
    @IBOutlet weak var locationErrorLabel: UILabel!

    @IBOutlet weak var saveButton: ButtonComponent!

    // MARK: - Dropdown Data
    private let roles = [
        "Frontend Developer","Backend Developer","Full Stack Developer",
        "Mobile App Developer","AI Engineer","Machine Learning Engineer",
        "Cybersecurity Specialist","IoT Developer","Embedded Systems Engineer",
        "Robotics Engineer","UI/UX Designer","Graphic Designer",
        "Project Manager","Pitch Presenter"
    ]

    private let genders = ["Male", "Female", "Other"]
    private let academicYears = ["1st Year","2nd Year","3rd Year","4th Year","5th Year","Alumni"]

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

    // MARK: - Dropdown Tables
    private let rolesTableView = UITableView()
    private let genderTableView = UITableView()
    private let academicYearTableView = UITableView()
    private let collegeTableView = UITableView()

    // MARK: - Selected Values
    private var selectedRoles = Set<String>()
    private var selectedGender: String?
    private var selectedAcademicYear: String?
    private var selectedCollege: String?

    // MARK: - Validation Flags
    private var isFirstNameValid = false
    private var isMiddleNameValid = true
    private var isLastNameValid = false
    private var isRolesValid = false
    private var isGenderValid = false
    private var isAcademicYearValid = false
    private var isCollegeValid = false
    private var isLocationValid = false

    // MARK: - Location
    private let locationManager = CLLocationManager()
    private var isRequestingLocation = false

    // Spinner
    private var spinner: UIActivityIndicatorView?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupTextFields()
        setupDropdownTables()
        addDropdownArrows()
        addLocationRightIcon()
        setupSaveButton()
        setupLocation()
    }

    // MARK: - UI Setup
    private func configureUI() {
        hideAllErrorLabels()
        setSaveButtonEnabled(false)
    }

    private func hideAllErrorLabels() {
        [
            firstNameErrorLabel, middleNameErrorLabel, lastNameErrorLabel,
            rolesErrorLabel, genderErrorLabel, academicYearErrorLabel,
            collegeErrorLabel, locationErrorLabel
        ].forEach { $0?.isHidden = true }
    }

    private func showLoading(_ show: Bool) {
        if show {
            if spinner == nil {
                spinner = UIActivityIndicatorView(style: .large)
                spinner?.translatesAutoresizingMaskIntoConstraints = false
                spinner?.hidesWhenStopped = true
                view.addSubview(spinner!)
                NSLayoutConstraint.activate([
                    spinner!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    spinner!.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
            }
            spinner?.startAnimating()
            view.isUserInteractionEnabled = false
        } else {
            spinner?.stopAnimating()
            view.isUserInteractionEnabled = true
        }
    }

    // MARK: - TextFields
    private func setupTextFields() {
        let fields = [
            firstNameTextField, middleNameTextField, lastNameTextField,
            rolesTextField, genderTextField,
            academicYearTextField, collegeTextField, locationTextField
        ]

        for tf in fields {
            guard let tf else { continue }
            tf.delegate = self
            tf.borderStyle = .none
            tf.layer.borderWidth = 1
            tf.layer.borderColor = UIColor.systemGray4.cgColor
            tf.layer.cornerRadius = 10

            let padding = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            tf.leftView = padding
            tf.leftViewMode = .always

            tf.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)

            // Disable keyboard for dropdown fields and location
            if tf != firstNameTextField && tf != middleNameTextField && tf != lastNameTextField {
                tf.inputView = UIView()
            }
        }
    }

    // MARK: - Dropdown Setup
    private func setupDropdownTables() {
        let tables = [rolesTableView, genderTableView, academicYearTableView, collegeTableView]

        for table in tables {
            table.layer.cornerRadius = 8
            table.layer.borderWidth = 1
            table.layer.borderColor = UIColor.systemGray4.cgColor
            table.isHidden = true
            table.delegate = self
            table.dataSource = self
            table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            table.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(table)
        }

        setupDropdownConstraints()

        rolesTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleRoles)))
        genderTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleGender)))
        academicYearTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleAcademic)))
        collegeTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleCollege)))
    }

    private func setupDropdownConstraints() {
        let map: [(UITableView, UITextField)] = [
            (rolesTableView, rolesTextField),
            (genderTableView, genderTextField),
            (academicYearTableView, academicYearTextField),
            (collegeTableView, collegeTextField)
        ]

        for (table, tf) in map {
            NSLayoutConstraint.activate([
                table.topAnchor.constraint(equalTo: tf.bottomAnchor, constant: 4),
                table.leadingAnchor.constraint(equalTo: tf.leadingAnchor),
                table.trailingAnchor.constraint(equalTo: tf.trailingAnchor),
                table.heightAnchor.constraint(equalToConstant: 220)
            ])
        }
    }

    // MARK: - Alerts
    private func showAlert(_ title: String,_ msg: String) {
        let a = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    // MARK: - Dropdown Arrows
    private func addDropdownArrows() {
        [rolesTextField, genderTextField, academicYearTextField, collegeTextField].forEach {
            addArrowIcon(to: $0!)
        }
    }

    private func addArrowIcon(to tf: UITextField) {
        let arrow = UIImageView(image: UIImage(systemName: "chevron.down"))
        arrow.tintColor = .gray
        arrow.contentMode = .scaleAspectFit

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
        arrow.frame = CGRect(x: 10, y: 2, width: 20, height: 20)
        container.addSubview(arrow)

        tf.rightView = container
        tf.rightViewMode = .always
    }

    private func rotateArrow(for tf: UITextField, open: Bool) {
        if let arrow = tf.rightView?.subviews.first {
            UIView.animate(withDuration: 0.25) {
                arrow.transform = open ? CGAffineTransform(rotationAngle: .pi) : .identity
            }
        }
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
    }

    // MARK: - Toggle Dropdowns
    @objc private func toggleRoles() { toggle(table: rolesTableView, field: rolesTextField) }
    @objc private func toggleGender() { toggle(table: genderTableView, field: genderTextField) }
    @objc private func toggleAcademic() { toggle(table: academicYearTableView, field: academicYearTextField) }
    @objc private func toggleCollege() { toggle(table: collegeTableView, field: collegeTextField) }

    private func toggle(table: UITableView, field: UITextField) {
        let show = table.isHidden
        closeAllDropdowns()
        table.isHidden = !show
        rotateArrow(for: field, open: show)
    }

    private func closeAllDropdowns() {
        rolesTableView.isHidden = true
        genderTableView.isHidden = true
        academicYearTableView.isHidden = true
        collegeTableView.isHidden = true

        rotateArrow(for: rolesTextField, open: false)
        rotateArrow(for: genderTextField, open: false)
        rotateArrow(for: academicYearTextField, open: false)
        rotateArrow(for: collegeTextField, open: false)
    }

    // MARK: - TextField Delegate
    func textFieldShouldBeginEditing(_ tf: UITextField) -> Bool {
        // Handle location field separately
        if tf == locationTextField {
            requestUserLocation()
            return false
        }
        
        // Allow only name fields to have keyboard
        if tf == firstNameTextField || tf == middleNameTextField || tf == lastNameTextField {
            return true
        }
        
        return false
    }

    // MARK: - Validation
    @objc func textFieldDidEndEditing(_ tf: UITextField) {
        validateTextField(tf)
        validateAllFields()
    }

    private func validateTextField(_ tf: UITextField) {
        let text = tf.text?.trimmingCharacters(in: .whitespaces) ?? ""

        switch tf {
        case firstNameTextField:
            isFirstNameValid = text.count >= 2
            updateError(firstNameErrorLabel, isFirstNameValid, "Enter valid first name")

        case middleNameTextField:
            isMiddleNameValid = true

        case lastNameTextField:
            isLastNameValid = text.count >= 2
            updateError(lastNameErrorLabel, isLastNameValid, "Enter valid last name")

        case rolesTextField:
            isRolesValid = selectedRoles.count >= 1 && selectedRoles.count <= 3
            updateError(rolesErrorLabel, isRolesValid, "Select 1–3 roles")

        case genderTextField:
            isGenderValid = selectedGender != nil
            updateError(genderErrorLabel, isGenderValid, "Select gender")

        case academicYearTextField:
            isAcademicYearValid = selectedAcademicYear != nil
            updateError(academicYearErrorLabel, isAcademicYearValid, "Select academic year")

        case collegeTextField:
            isCollegeValid = selectedCollege != nil
            updateError(collegeErrorLabel, isCollegeValid, "Select college")

        case locationTextField:
            isLocationValid = text.contains(",")
            updateError(locationErrorLabel, isLocationValid, "Format: City, Country")

        default: break
        }
    }

    private func updateError(_ label: UILabel?, _ valid: Bool, _ message: String) {
        label?.text = valid ? "" : message
        label?.isHidden = valid
    }

    private func validateAllFields() -> Bool {
        let valid =
            isFirstNameValid &&
            isMiddleNameValid &&
            isLastNameValid &&
            isRolesValid &&
            isGenderValid &&
            isAcademicYearValid &&
            isCollegeValid &&
            isLocationValid

        setSaveButtonEnabled(valid)
        return valid
    }

    // MARK: - Save Button
    private func setupSaveButton() {
        saveButton.configure(title: "Save & Continue")
        saveButton.onTap = { [weak self] in self?.completeSetup() }
    }

    private func setSaveButtonEnabled(_ enabled: Bool) {
        saveButton.button.isEnabled = enabled
        saveButton.alpha = enabled ? 1 : 0.5
    }

    // MARK: - Location
    private func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    private func requestUserLocation() {
        guard !isRequestingLocation else { return }
        isRequestingLocation = true

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            showAlert("Enable Location", "Please enable location in Settings.")
            isRequestingLocation = false
        @unknown default:
            isRequestingLocation = false
        }
    }

    // MARK: - Save → Update Profile in Supabase
    private func completeSetup() {
        guard let auth = authManager else {
            showAlert("Error", "Auth manager unavailable.")
            return
        }

        setSaveButtonEnabled(false)
        showLoading(true)

        // STEP 1: get user email
        auth.getUser { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let userObj):
                    let email = userObj["email"] as? String ?? ""
                    self.buildAndSendProfile(email: email, auth: auth)

                case .failure:
                    // fallback: decode from JWT
                    if let token = auth.currentSession?.accessToken,
                       let email = AuthManager.extractEmail(fromAccessToken: token) {
                        self.buildAndSendProfile(email: email, auth: auth)
                    } else {
                        self.showLoading(false)
                        self.setSaveButtonEnabled(true)
                        self.showAlert("Error", "Unable to fetch account email.")
                    }
                }
            }
        }
    }

    private func buildAndSendProfile(email: String, auth: AuthManager) {

        // NO USERNAME - let database trigger generate it
        let payload: [String: Any] = [
            "email": email,
            "first_name": firstNameTextField.text ?? "",
            "middle_name": middleNameTextField.text ?? "",
            "last_name": lastNameTextField.text ?? "",
            "roles": Array(selectedRoles),        // ARRAY column in Supabase
            "gender": selectedGender ?? "",
            "academic_year": selectedAcademicYear ?? "",
            "college": selectedCollege ?? "",
            "location": locationTextField.text ?? "",
            "role": "participant"
        ]

        auth.createProfile(payload: payload, maxRetries: 3) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                self.showLoading(false)
                self.setSaveButtonEnabled(true)

                switch result {
                case .success(let row):
                    print("Participant profile created successfully:", row)

                    UserDefaults.standard.set("participant", forKey: "UserRole")

                    // Move to participant home
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        sceneDelegate.changeRootViewController(ParticipantMainTabBarController())
                    }

                case .failure(let err):
                    self.showAlert("Profile Error", err.localizedDescription)
                }
            }
        }
    }
}

// MARK: - TableView
extension ParticipantProfileSetupViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == rolesTableView { return roles.count }
        if tableView == genderTableView { return genders.count }
        if tableView == academicYearTableView { return academicYears.count }
        return colleges.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if tableView == rolesTableView {
            let role = roles[indexPath.row]
            cell.textLabel?.text = role
            cell.accessoryType = selectedRoles.contains(role) ? .checkmark : .none
        }
        else if tableView == genderTableView {
            cell.textLabel?.text = genders[indexPath.row]
        }
        else if tableView == academicYearTableView {
            cell.textLabel?.text = academicYears[indexPath.row]
        }
        else {
            cell.textLabel?.text = colleges[indexPath.row]
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if tableView == rolesTableView {
            let role = roles[indexPath.row]

            if selectedRoles.contains(role) {
                selectedRoles.remove(role)
            } else if selectedRoles.count < 3 {
                selectedRoles.insert(role)
            } else {
                showAlert("Limit Reached", "You can select up to 3 roles.")
                return
            }

            rolesTextField.text = selectedRoles.joined(separator: ", ")
            validateTextField(rolesTextField)
            tableView.reloadRows(at: [indexPath], with: .none)
            validateAllFields()  // This is already here
            return
        }

        if tableView == genderTableView {
            selectedGender = genders[indexPath.row]
            genderTextField.text = selectedGender
            validateTextField(genderTextField)
        }

        if tableView == academicYearTableView {
            selectedAcademicYear = academicYears[indexPath.row]
            academicYearTextField.text = selectedAcademicYear
            validateTextField(academicYearTextField)
        }

        if tableView == collegeTableView {
            selectedCollege = colleges[indexPath.row]
            collegeTextField.text = selectedCollege
            validateTextField(collegeTextField)
        }

        closeAllDropdowns()
        
        // ADD VALIDATION FOR ALL FIELDS HERE
        validateTextField(firstNameTextField)
        validateTextField(middleNameTextField)
        validateTextField(lastNameTextField)
        validateTextField(rolesTextField)
        validateTextField(genderTextField)
        validateTextField(academicYearTextField)
        validateTextField(collegeTextField)
        validateTextField(locationTextField)
        
        validateAllFields()  // Final check
        tableView.reloadData()
    }
}

// MARK: - Location Delegate
extension ParticipantProfileSetupViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locs: [CLLocation]) {
        guard let loc = locs.first else { return }
        manager.stopUpdatingLocation()

        CLGeocoder().reverseGeocodeLocation(loc) { [weak self] places, _ in
            guard let self, let place = places?.first else { return }
            self.locationTextField.text = "\(place.locality ?? ""), \(place.country ?? "")"
            self.validateTextField(self.locationTextField)
            
            // ADD THIS: Validate all fields to enable button if everything is filled
            self.validateAllFields()
            
            self.isRequestingLocation = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isRequestingLocation = false
        showAlert("Location Error", "Unable to fetch location.")
    }
}
