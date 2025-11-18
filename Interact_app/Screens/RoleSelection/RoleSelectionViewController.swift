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
    
    enum Role {
            case organizer
            case participant
        }
        
        private var selectedRole: Role? = nil

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

        // MARK: - Setup
    
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
            // Initial card styling
            organizerSignupCard.layer.cornerRadius = 10
            participantSignupCard.layer.cornerRadius = 10
            
            organizerSignupCard.layer.borderWidth = 0
            participantSignupCard.layer.borderWidth = 0
            
            getStartButton.button.isEnabled = false
            getStartButton.configure(
                title: "Get started",
                imagePlacement: .trailing
                                       
            )
            getStartButton.button.isEnabled = false
            getStartButton.alpha = 0.5
            
            getStartButton.onTap = { [weak self] in
                    guard let self = self else { return }
                    guard let role = self.selectedRole else { return }

                    switch role {
                    case .organizer:
                        let organizerVC = SignupViewController(nibName: "SignupViewController", bundle: nil)
                        self.navigationController?.pushViewController(organizerVC, animated: true)
                    case .participant:
                        let participantVC = SignupParticipantViewController(nibName: "SignupParticipantViewController", bundle: nil)
                        self.navigationController?.pushViewController(participantVC, animated: true)
                    }
                }
        }
        
        private func setupGestures() {
            let organizerTap = UITapGestureRecognizer(target: self, action: #selector(selectOrganizer))
            let participantTap = UITapGestureRecognizer(target: self, action: #selector(selectParticipant))
            
            organizerSignupCard.addGestureRecognizer(organizerTap)
            participantSignupCard.addGestureRecognizer(participantTap)
        }

        // MARK: - Selection Handling
        
        @objc private func selectOrganizer() {
            selectRole(.organizer)
        }
        
        @objc private func selectParticipant() {
            selectRole(.participant)
        }
        
        private func selectRole(_ role: Role) {
            selectedRole = role
            
            // Reset both borders
            organizerSignupCard.layer.borderWidth = 0
            participantSignupCard.layer.borderWidth = 0
            
            // Animate selected border
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
            
            // Enable "Get Started"
            getStartButton.button.isEnabled = true
            getStartButton.alpha = 1.0
        }
    
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
}
