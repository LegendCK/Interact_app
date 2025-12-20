//
//  VerifyAccountViewController.swift
//  Interact_app
//

import UIKit

class VerifyAccountViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var verifyButton: ButtonComponent!

    // Email passed from SignupViewController for resend functionality
    var userEmail: String?

    // Auth manager
    var authManager: AuthManager? {
        if let scene = UIApplication.shared.connectedScenes.first,
           let delegate = scene.delegate as? SceneDelegate {
            return delegate.authManager
        }
        return nil
    }

    private var timer: Timer?
    private var counter = 30
    private var canResend = false

    // Spinner
    private var spinner: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        startTimer()
    }

    private func setupUI() {
        verifyButton.configure(
            title: "I've Verified",
            backgroundColor: .systemBlue,
            font: .systemFont(ofSize: 17, weight: .semibold)
        )

        verifyButton.button.isEnabled = true
        verifyButton.alpha = 1.0

        verifyButton.onTap = { [weak self] in
            self?.verifiedTapped()
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(infoLabelTapped))
        infoLabel.isUserInteractionEnabled = false
        infoLabel.addGestureRecognizer(tap)

        updateCountdownText()
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

    // MARK: - Timer Logic
    private func startTimer() {
        counter = 30
        canResend = false

        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(updateTimer),
                                     userInfo: nil,
                                     repeats: true)
    }

    @objc private func updateTimer() {
        if counter > 0 {
            counter -= 1
            updateCountdownText()
        } else {
            timer?.invalidate()
            timer = nil
            showResendText()
        }
    }

    private func updateCountdownText() {
        infoLabel.text = "Didn't get the verification link? Try again in \(counter)s"
        infoLabel.textColor = .gray
    }

    private func showResendText() {
        canResend = true

        let base = "Didn't get the verification link? "
        let resend = "Resend"

        let attributed = NSMutableAttributedString(
            string: base,
            attributes: [
                .foregroundColor: UIColor.gray,
                .font: UIFont.systemFont(ofSize: 14)
            ]
        )

        let resendAttr = NSAttributedString(
            string: resend,
            attributes: [
                .foregroundColor: UIColor.systemBlue,
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )

        attributed.append(resendAttr)

        infoLabel.attributedText = attributed
        infoLabel.isUserInteractionEnabled = true
    }

    // MARK: - Resend
    @objc private func infoLabelTapped() {
        guard canResend else { return }
        guard let email = userEmail else {
            presentAlert(title: "Error", message: "Email not found. Please try signing up again.")
            return
        }

        print("Resend tapped for email: \(email)")

        guard let auth = authManager else {
            presentAlert(title: "Error", message: "Auth manager not available")
            return
        }

        infoLabel.isUserInteractionEnabled = false
        showLoading(true)

        auth.resendVerificationEmail(email: email) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.showLoading(false)

                switch result {
                case .success():
                    self.presentAlert(title: "Email Sent", message: "Verification email has been resent. Please check your inbox.")
                    self.startTimer() // Restart countdown

                case .failure(let error):
                    self.presentAlert(title: "Resend Failed", message: error.localizedDescription)
                    // Still allow user to try again
                    self.showResendText()
                }
            }
        }
    }

    // MARK: - Verified Button Tapped (Redirect to Login)
    private func verifiedTapped() {
        print("I've Verified tapped - redirecting to login")

        let alert = UIAlertController(
            title: "Email Verified?",
            message: "Great! Please sign in again to continue with your verified account.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Sign In", style: .default) { [weak self] _ in
            // Pop back to login screen
            self?.navigationController?.popToRootViewController(animated: true)
        })

        present(alert, animated: true)
    }

    private func presentAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    deinit {
        timer?.invalidate()
    }
}
