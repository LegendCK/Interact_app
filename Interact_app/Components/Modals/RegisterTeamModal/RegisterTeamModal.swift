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
    
    @IBOutlet weak var continueTeamButton: ButtonComponent!
    
    
    // MARK: - Properties
        var eventID: UUID?
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupNavigation()
            configureButtonUI()
            setupTextFields()
            
            // Link target programmatically (or ensure it's linked in Storyboard)
//            continueTeamButton.addTarget(self, action: #selector(continueButtonTapped(_:)), for: .touchUpInside)
        }
            
        // MARK: - Navigation
        private func setupNavigation() {
            title = "Register Team"
//            navigationItem.leftBarButtonItem = UIBarButtonItem(
//                barButtonSystemItem: .close,
//                target: self,
//                action: #selector(didTapDismiss)
//            )
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                    title: "Done",
                    style: .done,
                    target: self,
                    action: #selector(didTapDone)
                )
        }
    
    @objc private func didTapDone() {
        dismiss(animated: true)
    }
    
    private func setupTextFields() {
        let fields: [UITextField?] = [
            teamName,
            leaderName,
            leaderEmail,
            leaderPhoneNumber
        ]
        
        fields.forEach { textField in
            guard let field = textField else { return }
            
//            field.delegate = self
            field.borderStyle = .none
            field.layer.borderColor = UIColor.systemGray4.cgColor
            field.layer.borderWidth = 1
            field.layer.cornerRadius = 10
            
            // Fix: Use field.frame.height for dynamic padding
            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.height))
            field.leftView = leftPaddingView
            field.leftViewMode = .always
        }
    }
            
        @objc private func didTapDismiss() {
            dismiss(animated: true)
        }
            
        // MARK: - Button Setup
    private func configureButtonUI() {
        // Using ButtonComponent's configure method
        continueTeamButton.configure(
            title: "Continue",
            titleColor: .white,
            backgroundColor: .systemBlue,
            cornerRadius: 10,
            font: .systemFont(ofSize: 16, weight: .semibold)
        )
        
        // Set the onTap action
        continueTeamButton.onTap = { [weak self] in
            self?.handleCreateTeam()
        }
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
        
        // 2. UI Loading State - Use ButtonComponent's properties
        continueTeamButton.isEnabled = false
        continueTeamButton.updateTitle("Creating...")
        continueTeamButton.updateBackgroundColor(.systemGray)
        
        Task {
            do {
                // 3. Call API: Create Team and get the new ID
                let newTeamID = try await TeamService.shared.createTeam(eventID: validEventID, name: name)
                
                print("✅ Team Created Successfully. ID: \(newTeamID)")
                
                DispatchQueue.main.async {
                    // 4. Navigate to the "Add Teammates" Modal
                    let createTeamVC = CreateTeamModal()
                    
                    // PASS THE ID FORWARD
                    createTeamVC.teamID = newTeamID
                    
                    self.navigationController?.pushViewController(createTeamVC, animated: true)
                    
                    // Reset button state (in case they come back)
                    self.continueTeamButton.isEnabled = true
                    self.continueTeamButton.updateTitle("Continue")
                    self.continueTeamButton.updateBackgroundColor(.systemBlue)
                }
            } catch {
                print("❌ Error: \(error)")
                
                DispatchQueue.main.async {
                    // Re-enable button on error
                    self.continueTeamButton.isEnabled = true
                    self.continueTeamButton.updateTitle("Continue")
                    self.continueTeamButton.updateBackgroundColor(.systemBlue)
                    
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
