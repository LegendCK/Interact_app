//
//  RoleSelectionViewController.swift
//  Interact_app
//

import UIKit

class RoleSelectionViewController: UIViewController {

    @IBOutlet weak var screenTitleLabel: UILabel!
    @IBOutlet weak var organizerSignupCard: UIView!
    @IBOutlet weak var participantSignupCard: UIView!
    @IBOutlet weak var getStartButton: ButtonComponent!
    @IBOutlet weak var alreadyHaveAccLabel: UILabel!

    private var selectedRole: UserRole? = nil

    // Auth manager
    var authManager: AuthManager? {
        if let scene = UIApplication.shared.connectedScenes.first,
           let delegate = scene.delegate as? SceneDelegate {
            return delegate.authManager
        }
        return nil
    }

    // Spinner
    private var spinner: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupGestures()
        styleScreenTitle()

        let tap = UITapGestureRecognizer(target: self, action: #selector(backToLoginTapped))
        alreadyHaveAccLabel.isUserInteractionEnabled = true
        alreadyHaveAccLabel.addGestureRecognizer(tap)
    }

    @objc func backToLoginTapped() {
        navigateBackToLogin()
    }

    // MARK: - Loading Indicator
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

    // MARK: - Setup UI

    private func styleScreenTitle() {
        let fullText = "How will you use Interact?"
        let coloredPart = "Interact?"

        let attributedString = NSMutableAttributedString(string: fullText)

        if let range = fullText.range(of: coloredPart) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.foregroundColor,
                                          value: UIColor.systemBlue,
                                          range: nsRange)
        }

        screenTitleLabel.attributedText = attributedString
    }

    private func setupUI() {
        organizerSignupCard.layer.cornerRadius = 10
        participantSignupCard.layer.cornerRadius = 10

        organizerSignupCard.layer.borderWidth = 0
        participantSignupCard.layer.borderWidth = 0

        getStartButton.configure(title: "Get Started", imagePlacement: .trailing)
        setGetStartedEnabled(false)

        getStartButton.onTap = { [weak self] in
            guard let self = self, let role = self.selectedRole else { return }
            self.updateRoleAndProceed(role: role)
        }
    }

    private func setGetStartedEnabled(_ enabled: Bool) {
        getStartButton.button.isEnabled = enabled
        getStartButton.alpha = enabled ? 1.0 : 0.5
    }

    private func setupGestures() {
        organizerSignupCard.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(selectOrganizer))
        )
        participantSignupCard.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(selectParticipant))
        )
    }

    // MARK: - Role Selection

    @objc private func selectOrganizer() { selectRole(.organizer) }
    @objc private func selectParticipant() { selectRole(.participant) }

    private func selectRole(_ role: UserRole) {
        selectedRole = role

        organizerSignupCard.layer.borderWidth = 0
        participantSignupCard.layer.borderWidth = 0

        UIView.animate(withDuration: 0.2) {
            switch role {
            case .organizer:
                self.organizerSignupCard.layer.borderWidth = 2
                self.organizerSignupCard.layer.borderColor = UIColor.systemBlue.cgColor
            case .participant:
                self.participantSignupCard.layer.borderWidth = 2
                self.participantSignupCard.layer.borderColor = UIColor.systemOrange.cgColor
            }
        }

        setGetStartedEnabled(true)
    }

    // MARK: - Update Role in Database and Proceed
    private func updateRoleAndProceed(role: UserRole) {
        guard let auth = authManager else {
            presentAlert(title: "Error", message: "Auth manager not available")
            return
        }

        setGetStartedEnabled(false)
        showLoading(true)

        // Update role in profiles table
        auth.updateProfileRole(role: role.rawValue) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.setGetStartedEnabled(true)
                self.showLoading(false)

                switch result {
                case .success(let updatedProfile):
                    print("Role updated successfully:", updatedProfile)
                    
                    // Save to UserDefaults for quick access
                    UserDefaults.standard.set(role.rawValue, forKey: "UserRole")
                    
                    // Navigate to respective profile setup screen
                    self.navigateToProfileSetup(role: role)

                case .failure(let error):
                    print("Failed to update role:", error)
                    self.presentAlert(
                        title: "Update Failed",
                        message: "Unable to save your role selection. Please try again. Error: \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    // MARK: - Navigation
    private func navigateToProfileSetup(role: UserRole) {
        switch role {
        case .organizer:
            let vc = OrgProfileSetupViewController(nibName: "OrgProfileSetupViewController", bundle: nil)
            vc.userRole = .organizer
            navigationController?.pushViewController(vc, animated: true)

        case .participant:
            let vc = ParticipantProfileSetupViewController(nibName: "ParticipantProfileSetupViewController", bundle: nil)
            vc.userRole = .participant
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func navigateBackToLogin() {
        // Pop back to login (assuming login is in the navigation stack)
        navigationController?.popToRootViewController(animated: true)
    }

    private func presentAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
