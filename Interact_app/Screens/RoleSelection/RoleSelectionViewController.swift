//
//  RoleSelectionViewController.swift
//  Interact_app
//
//  Created by admin56 on 07/11/25.
//

import UIKit

class RoleSelectionViewController: UIViewController {

    @IBOutlet weak var organizerSignupCard: UIView!
    @IBOutlet weak var participantSignupCard: UIView!
    @IBOutlet weak var getStartedButton: UIButton!

    enum Role {
            case organizer
            case participant
        }
        
        private var selectedRole: Role? = nil

        override func viewDidLoad() {
            super.viewDidLoad()
            
            setupUI()
            setupGestures()
        }

        // MARK: - Setup
        
        private func setupUI() {
            // Initial card styling
            organizerSignupCard.layer.cornerRadius = 10
            participantSignupCard.layer.cornerRadius = 10
            
            organizerSignupCard.layer.borderWidth = 0
            participantSignupCard.layer.borderWidth = 0
            
            getStartedButton.isEnabled = false
            getStartedButton.alpha = 0.5
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
            getStartedButton.isEnabled = true
            getStartedButton.alpha = 1.0
        }

        // MARK: - Navigation
        
    @IBAction func getStartedTapped(_ sender: UIButton) {
        guard let role = selectedRole else { return }
        
        switch role {
        case .organizer:
            let organizerVC = SignupViewController(nibName: "SignupViewController", bundle: nil)
            navigationController?.pushViewController(organizerVC, animated: true)
            
        case .participant:
            let participantVC = SignupParticipantViewController(nibName: "SignupParticipantViewController", bundle: nil)
            navigationController?.pushViewController(participantVC, animated: true)
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
}
