//
//  RoleSelectionViewController.swift
//  Interact_app
//
//  Created by admin56 on 07/11/25.
//

import UIKit

class RoleSelectionViewController: UIViewController {

    @IBOutlet weak var screenTitleLabel: UILabel!
    @IBOutlet weak var organizerSignupCard: UIView!
    @IBOutlet weak var participantSignupCard: UIView!
    @IBOutlet weak var getStartButton: ButtonComponent!
    @IBOutlet weak var alreadyHaveAccLabel: UILabel!

    private var selectedRole: UserRole? = nil

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
        goToLoginScreen()
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

            switch role {

            case .organizer:
                let vc = OrgProfileSetupViewController(nibName: "OrgProfileSetupViewController", bundle: nil)
                vc.userRole = .organizer
                self.navigationController?.pushViewController(vc, animated: true)

            case .participant:
                let vc = ParticipantProfileSetupViewController(nibName: "ParticipantProfileSetupViewController", bundle: nil)
                vc.userRole = .participant
                self.navigationController?.pushViewController(vc, animated: true)
            }
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
}
