//
//  InviteTeamMembersModal.swift
//  Interact_app
//
//  Created by admin73 on 18/01/26.
//

import UIKit

class InviteTeamMembersModal: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cancelButton: ButtonComponent!
    
    @IBOutlet weak var sendInvitesButton: ButtonComponent!
    
    // MARK: - Properties
        var existingTeamID: UUID?
        
        private var allConnections: [ProfileLite] = []
        private var filteredConnections: [ProfileLite] = []
        private var selectedUserIDs: Set<UUID> = []
        
        private let currentUserId = UserDefaults.standard.string(forKey: "supabase_user_id") ?? ""
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupNavigation()
            setupTableView()
            setupSearchBar()
            setupButtons()
            fetchAcceptedConnections()
        }
        
        // MARK: - Navigation
        private func setupNavigation() {
            title = "Invite Connections"
            navigationItem.hidesBackButton = true
        }

        // MARK: - Setup UI
        private func setupTableView() {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.rowHeight = 66
            // Ensure this Nib name matches your file name exactly
            tableView.register(UINib(nibName: "ConnectionsList", bundle: nil), forCellReuseIdentifier: "ConnectionsList")
        }
        
        private func setupSearchBar() {
            searchBar.delegate = self
            searchBar.placeholder = "Search connections..."
            searchBar.backgroundImage = UIImage()
        }
        
        private func setupButtons() {
            // 1. Configure Cancel Button (Gray/Clear style)
            cancelButton.configure(
                title: "Cancel",
                titleColor: .systemGray,
                backgroundColor: .systemGray6, // or .systemGray6
                font: .systemFont(ofSize: 16, weight: .regular)
            )
            
            cancelButton.onTap = { [weak self] in
                // Go back to the previous screen (CreateTeamModal)
                self?.navigationController?.popViewController(animated: true)
            }
            
            // 2. Configure Send Button (Initially Disabled style)
            sendInvitesButton.configure(
                title: "Send Invites (0)",
                titleColor: .white,
                backgroundColor: .systemGray,
                font: .systemFont(ofSize: 16, weight: .semibold)
            )
            sendInvitesButton.isEnabled = false
            
            sendInvitesButton.onTap = { [weak self] in
                self?.handleSendInvites()
            }
        }
        
        // Update the button text and color based on selection
        private func updateSendButtonState() {
            let count = selectedUserIDs.count
            let title = "Send Invites (\(count))"
            
            // Use the new helper methods we added to ButtonComponent
            sendInvitesButton.updateTitle(title)
            
            if count > 0 {
                sendInvitesButton.updateBackgroundColor(.systemBlue)
                sendInvitesButton.isEnabled = true
            } else {
                sendInvitesButton.updateBackgroundColor(.systemGray)
                sendInvitesButton.isEnabled = false
            }
        }

        // MARK: - API Calls
        
        private func fetchAcceptedConnections() {
            Task {
                do {
                    // This function returns [ProfileLite] directly
                    let connections = try await ConnectionService.shared.fetchAcceptedFriends()
                    
                    DispatchQueue.main.async {
                        self.allConnections = connections
                        self.filteredConnections = connections
                        self.tableView.reloadData()
                    }
                } catch {
                    print("❌ Error fetching connections: \(error)")
                }
            }
        }
        
        private func handleSendInvites() {
            guard let teamID = existingTeamID else {
                print("❌ No Team ID found")
                return
            }
            
            let selectedList = Array(selectedUserIDs)
            guard !selectedList.isEmpty else { return }
            
            // UI Loading State
            sendInvitesButton.updateTitle("Sending...")
            sendInvitesButton.isEnabled = false
            
            Task {
                do {
                    try await TeamService.shared.inviteMembers(teamID: teamID, userIds: selectedList)
                    
                    print("✅ Invites sent successfully")
                    
                    DispatchQueue.main.async {
                        // Success! Pop back to the previous screen
                        self.navigationController?.popViewController(animated: true)
                    }
                } catch {
                    print("❌ Error inviting members: \(error)")
                    
                    DispatchQueue.main.async {
                        self.updateSendButtonState() // Reset UI
                        self.showAlert(message: "Failed to send invites: \(error.localizedDescription)")
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
// MARK: - TableView DataSource & Delegate
extension InviteTeamMembersModal: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredConnections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionsList", for: indexPath) as? ConnectionsList else {
            return UITableViewCell()
        }
        
        // The array is already just the friends!
        let friend = filteredConnections[indexPath.row]
        
        let isSelected = selectedUserIDs.contains(friend.id)
        
        // Ensure your ConnectionsList cell has a configure method
        // You might need to add `isSelected` to your cell's UI logic (e.g., show a checkmark)
        cell.configure(with: friend, isSelected: isSelected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let friend = filteredConnections[indexPath.row]
        toggleSelection(for: friend.id)
    }
    
    private func toggleSelection(for userId: UUID) {
        if selectedUserIDs.contains(userId) {
            selectedUserIDs.remove(userId)
        } else {
            selectedUserIDs.insert(userId)
        }
        
        // Refresh UI
        tableView.reloadData()
        updateSendButtonState()
    }
}

// MARK: - SearchBar Delegate
extension InviteTeamMembersModal: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredConnections = allConnections
        } else {
            filteredConnections = allConnections.filter { friend in
                
                let nameMatch = friend.fullName.lowercased().contains(searchText.lowercased())
                let roleMatch = friend.primaryRole?.lowercased().contains(searchText.lowercased()) ?? false
                
                return nameMatch || roleMatch
            }
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
