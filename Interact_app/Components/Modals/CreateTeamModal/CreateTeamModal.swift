//
//  CreateTeamModal.swift
//  Interact_app
//
//  Created by admin73 on 18/01/26.
//

import UIKit

class CreateTeamModal: UIViewController {
    
    @IBOutlet weak var inviteConnectionsButton: ButtonComponent!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var TeamLimitsLabel: UILabel!
    
        
    // MARK: - Properties
        var teamID: UUID? // Passed from previous screen
        
        // Data Sources
        private var acceptedMembers: [TeamMemberDisplay] = []
        private var pendingMembers: [TeamMemberDisplay] = []

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupNavigation()
            setupButton()
            setupTableView()
            updateLimitsLabel()
        }
        
        
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // Reload data every time the view appears (e.g., after returning from the Invite screen)
            loadTeamMembers()

            // Setup Sheet presentation
            if let sheet = navigationController?.sheetPresentationController {
                sheet.animateChanges {
                    sheet.detents = [.medium(), .large()]
                    sheet.selectedDetentIdentifier = .large
                    sheet.prefersGrabberVisible = true
                }
            }
        }
        
        // MARK: - Data Loading
        private func loadTeamMembers() {
            guard let validTeamID = teamID else {
                print("❌ Team ID missing")
                return
            }
            
            Task {
                do {
                    // Fetch all members
                    let allMembers = try await TeamService.shared.fetchTeamMembers(for: validTeamID)
                    
                    // Filter into two arrays based on status
                    self.acceptedMembers = allMembers.filter { $0.status == "accepted" }
                    self.pendingMembers = allMembers.filter { $0.status == "pending" }
                    
                    // Refresh Table
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch {
                    print("❌ Error loading team members: \(error)")
                }
            }
        }
    
    private func updateLimitsLabel() {
            guard let validTeamID = teamID else { return }
            
            Task {
                do {
                    // ✅ Use your corrected function here
                    let (min, max) = try await TeamService.shared.fetchTeamLimits(teamId: validTeamID)
                    
                    DispatchQueue.main.async {
                        // Handle case where limits might be 0 (e.g. data not found)
                        if max > 0 {
                            self.TeamLimitsLabel.text = "This event requires \(min)-\(max) members."
                        } else {
                            self.TeamLimitsLabel.text = "Team requirements loading..."
                        }
                    }
                } catch {
                    print("Failed to fetch event limits: \(error)")
                }
            }
        }
        
        // MARK: - Setup UI
        private func setupTableView() {
            tableView.delegate = self
            tableView.dataSource = self
            
            // ✅ Register your Custom Cell XIB
            // "TeammateStatusCell" must match the filename of your .xib
            let nib = UINib(nibName: "TeammateStatusCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "TeammateStatusCell")
            
            // Hide empty rows at the bottom
            tableView.tableFooterView = UIView()
            
            // Remove default separators if your custom cell handles them, or keep them
            tableView.separatorStyle = .singleLine
        }
        
        func setupButton() {
            inviteConnectionsButton.configure(
                title: "Invite from Connections",
                titleColor: .white,
                backgroundColor: .systemBlue,
                image: UIImage(systemName: "plus"),
                imagePlacement: .leading
            )
            
            inviteConnectionsButton.onTap = { [weak self] in
                self?.handleInviteTapped()
            }

        }
        
        // MARK: - Navigation
        private func setupNavigation() {
            title = "Manage Team"
            navigationItem.hidesBackButton = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Done",
                style: .done,
                target: self,
                action: #selector(didTapDismiss)
            )
        }
        
        @objc private func didTapDismiss() {
            dismiss(animated: true)
        }
        
        // MARK: - Actions
        private func handleInviteTapped() {
            guard let validTeamID = teamID else { return }
            
            let inviteVC = InviteTeamMembersModal()
            inviteVC.existingTeamID = validTeamID
            self.navigationController?.pushViewController(inviteVC, animated: true)
        }
    
    private func handleConfirmTeam() {
            guard let validTeamID = teamID else { return }
            print("✅ Confirm Team tapped for ID: \(validTeamID)")

            // 1. Basic Client-Side Validation (Optional but fast)
            if acceptedMembers.isEmpty {
                showErrorAlert(message: "You cannot register an empty team.")
                return
            }

            // 2. Call the Database Function
            Task {
                do {
                    // This calls the RPC 'confirm_team_registration' in TeamService
                    let result = try await TeamService.shared.confirmTeamRegistration(teamId: validTeamID)
                    
                    // 3. Handle the Result on the Main Thread
                    DispatchQueue.main.async {
                        if result == "success" {
                            self.handleSuccess()
                        } else {
                            // The DB returned a specific logic error (e.g. "team_too_small")
                            let message = self.readableError(from: result)
                            self.showErrorAlert(message: message)
                        }
                    }
                } catch {
                    // Network or System Error
                    DispatchQueue.main.async {
                        print("❌ System Error: \(error)")
                        self.showErrorAlert(message: "Could not connect to the server. Please check your internet connection.")
                    }
                }
            }
        }

        // MARK: - Helper Functions

        /// Converts raw database error codes into user-friendly messages
        private func readableError(from code: String) -> String {
            switch code {
            case "team_too_small":
                return "Your team does not have enough accepted members to join this event."
            case "team_too_big":
                return "Your team exceeds the maximum size allowed for this event."
            case "already_registered":
                return "This team is already registered for the event."
            case "event_not_found":
                return "The event associated with this team could not be found."
            default:
                return "Registration failed: \(code)"
            }
        }

        private func handleSuccess() {
            let alert = UIAlertController(title: "Success!", message: "Your team has been officially registered for the event.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Awesome", style: .default, handler: { _ in
                // Dismiss the modal to return to the previous screen
                self.dismiss(animated: true)
                // Optional: Post a notification if the parent screen needs to refresh
                NotificationCenter.default.post(name: NSNotification.Name("TeamRegistered"), object: nil)
            }))
            self.present(alert, animated: true)
        }

        private func showErrorAlert(message: String) {
            let alert = UIAlertController(title: "Registration Failed", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }

}

// MARK: - TableView Delegate & DataSource
extension CreateTeamModal: UITableViewDelegate, UITableViewDataSource {
    
    // 1. Number of Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // 2. Section Headers
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground // or .secondarySystemBackground
        
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        if section == 0 {
            // Only show header if we have accepted members
            label.text = acceptedMembers.isEmpty ? "" : "Your Team"
        } else {
            // Only show header if we have pending invites
            label.text = pendingMembers.isEmpty ? "" : "Invited Members (Pending)"
        }
        
        // Hide header logic
        if label.text == "" { return nil }
        
        headerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return acceptedMembers.isEmpty ? 0 : 40
        } else {
            return pendingMembers.isEmpty ? 0 : 40
        }
    }
    
    // 3. Number of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return acceptedMembers.count
        } else {
            return pendingMembers.count
        }
    }
    
    // 4. Cell Configuration
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TeammateStatusCell", for: indexPath) as? TeammateStatusCell else {
            return UITableViewCell()
        }
        
        // Determine which member to show based on section
        let member = (indexPath.section == 0) ? acceptedMembers[indexPath.row] : pendingMembers[indexPath.row]
        
        // Configure the custom cell
        cell.configure(with: member)
        
        return cell
    }
    
    // 5. Row Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66 // Adjust this based on how tall your XIB design is
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        // Only after section 0
        guard section == 0 else { return nil }
        guard !acceptedMembers.isEmpty else { return nil }

        let containerView = UIView()
        containerView.backgroundColor = .clear

        let confirmButton = ButtonComponent()
        confirmButton.translatesAutoresizingMaskIntoConstraints = false

        confirmButton.configure(
            title: "Confirm Team",
            titleColor: .white,
            backgroundColor: .systemBlue
        )

        confirmButton.onTap = { [weak self] in
            self?.handleConfirmTeam()
        }

        containerView.addSubview(confirmButton)

        NSLayoutConstraint.activate([
            confirmButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            confirmButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            confirmButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            confirmButton.heightAnchor.constraint(equalToConstant: 48)
        ])

        return containerView
    }

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 && !acceptedMembers.isEmpty {
            return 72
        }
        return 0
    }

}
