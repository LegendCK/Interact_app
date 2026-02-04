//
//  RegisterTeamModal.swift
//  Interact_app
//
//  Created by admin73 on 18/01/26.
//

import UIKit

class RegisterTeamModal: UIViewController {
    
    @IBOutlet weak var teamName: UITextField!
    
    @IBOutlet weak var leaderName: UITextField!
    
    @IBOutlet weak var leaderEmail: UITextField!
    
    @IBOutlet weak var leaderPhoneNumber: UITextField!
    
    @IBOutlet weak var continueTeamButton: UIButton!
    
    // MARK: - Properties
        var eventID: UUID?
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupNavigation()
            configureButtonUI()
            
            // Link target programmatically (or ensure it's linked in Storyboard)
            continueTeamButton.addTarget(self, action: #selector(continueButtonTapped(_:)), for: .touchUpInside)
        }
            
        // MARK: - Navigation
        private func setupNavigation() {
            title = "Register Team"
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(didTapDismiss)
            )
        }
            
        @objc private func didTapDismiss() {
            dismiss(animated: true)
        }
            
        // MARK: - Button Setup
        private func configureButtonUI() {
            continueTeamButton.backgroundColor = .systemBlue
            continueTeamButton.setTitle("Continue", for: .normal)
            continueTeamButton.setTitleColor(.white, for: .normal)
            continueTeamButton.layer.cornerRadius = 10
            continueTeamButton.clipsToBounds = true
        }

        // MARK: - Actions
        @IBAction func continueButtonTapped(_ sender: UIButton) {
            handleCreateTeam()
        }
            
        // MARK: - Logic
        private func handleCreateTeam() {
            // 1. Validation
            guard let name = teamName.text, !name.isEmpty else {
                showAlert(message: "Please enter a Team Name.")
                return
            }
            
            guard let validEventID = eventID else {
                showAlert(message: "Error: No Event ID passed to this screen.")
                return
            }
            
            // 2. UI Loading State
            continueTeamButton.isEnabled = false
            continueTeamButton.backgroundColor = .systemGray
            continueTeamButton.setTitle("Creating...", for: .normal)
            
            Task {
                do {
                    // 3. Call API: Create Team and get the new ID
                    // Note: Ensure your TeamService.createTeam returns 'UUID' as discussed!
                    let newTeamID = try await TeamService.shared.createTeam(eventID: validEventID, name: name)
                    
                    print("✅ Team Created Successfully. ID: \(newTeamID)")
                    
                    DispatchQueue.main.async {
                        // 4. Navigate to the "Add Teammates" Modal
                        // Ensure CreateTeamModal is instantiated correctly (if using Storyboard, use storyboard.instantiate...)
                        let createTeamVC = CreateTeamModal()
                        
                        // PASS THE ID FORWARD
                        createTeamVC.teamID = newTeamID
                        
                        self.navigationController?.pushViewController(createTeamVC, animated: true)
                        
                        // Reset button state (in case they come back)
                        self.continueTeamButton.isEnabled = true
                        self.continueTeamButton.backgroundColor = .systemBlue
                        self.continueTeamButton.setTitle("Continue", for: .normal)
                    }
                } catch {
                    print("❌ Error: \(error)")
                    
                    DispatchQueue.main.async {
                        // Re-enable button on error
                        self.continueTeamButton.isEnabled = true
                        self.continueTeamButton.backgroundColor = .systemBlue
                        self.continueTeamButton.setTitle("Continue", for: .normal)
                        
                        self.showAlert(message: "Failed: \(error.localizedDescription)")
                    }
                }
            }
        }
            
        private func showAlert(message: String) {
            let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
}
