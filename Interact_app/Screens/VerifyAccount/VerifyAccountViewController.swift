//
//  VerifyAccountViewController.swift
//  Interact_app
//
//  Created by admin56 on 07/11/25.
//

//
//  VerifyAccountViewController.swift
//  Interact_app
//
//  Created by admin56 on 07/11/25.
//

import UIKit

class VerifyAccountViewController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var verifyButton: ButtonComponent!

    private var timer: Timer?
    private var counter = 30
    private var canResend = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        startTimer()
    }

    private func setupUI() {
        // Configure the Verify button
        verifyButton.configure(
            title: "I've Verified",
            backgroundColor: .systemBlue,
            font: .systemFont(ofSize: 17, weight: .semibold)
        )

        // Disable it initially
        verifyButton.button.isEnabled = false
        verifyButton.alpha = 0.5

        // On tap callback
        verifyButton.onTap = { [weak self] in
            self?.verifiedTapped()
        }

        // Label tap gesture for Resend
        let tap = UITapGestureRecognizer(target: self, action: #selector(infoLabelTapped))
        infoLabel.isUserInteractionEnabled = false
        infoLabel.addGestureRecognizer(tap)

        updateCountdownText()
    }

    // MARK: - Timer Logic
    private func startTimer() {
        counter = 1
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
        infoLabel.attributedText = nil
        infoLabel.text = "Didn’t get the verification link? Try again in \(counter)s"
        infoLabel.textColor = .gray
    }

    private func showResendText() {
        canResend = true

        // Enable the custom button
        verifyButton.button.isEnabled = true
        verifyButton.alpha = 1.0

        // Create underlined "Resend" text
        let base = "Didn’t get the verification link? "
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

    // MARK: - Resend Email
    @objc private func infoLabelTapped() {
        guard canResend else { return }
        print("Resend tapped")

        // Disable while timer resets
        verifyButton.button.isEnabled = false
        verifyButton.alpha = 0.5

        infoLabel.isUserInteractionEnabled = false

        startTimer()

        // TODO: call resend API
    }

    // MARK: - Verified Action
    private func verifiedTapped() {
        print("I've Verified tapped")
        navigateToSetupProfile()
    }

    private func navigateToSetupProfile() {
        let orgVC = OrgProfileSetupViewController(
            nibName: "OrgProfileSetupViewController",
            bundle: nil
        )
        navigationController?.pushViewController(orgVC, animated: true)
    }
}
