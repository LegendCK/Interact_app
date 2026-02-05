//
//  ManageTeamModal.swift
//  Interact_app
//
//  Created by admin73 on 04/02/26.
//

import UIKit

class ManageTeamModal: UIViewController {
    
    @IBOutlet weak var inviteConnectionsButton: ButtonComponent!
    
    @IBOutlet weak var acceptedMembersTableView: UITableView!
    @IBOutlet weak var pendingMembersTableView: UITableView!
    
    @IBOutlet weak var TeamLimitsLabel: UILabel!
    
    @IBOutlet weak var acceptedTableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var pendingTableHeight: NSLayoutConstraint!
    
    // MARK: - Properties
        var teamID: UUID?

        private var acceptedMembers: [TeamMemberDisplay] = []
        private var pendingMembers: [TeamMemberDisplay] = []

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupTableViews()
            loadInitialData()
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            updateTableViewHeights()
        }

        // MARK: - Setup
        private func setupTableViews() {

            acceptedMembersTableView.delegate = self
            acceptedMembersTableView.dataSource = self

            pendingMembersTableView.delegate = self
            pendingMembersTableView.dataSource = self

            acceptedMembersTableView.separatorStyle = .none
            pendingMembersTableView.separatorStyle = .none

            // IMPORTANT: Disable internal scrolling
            acceptedMembersTableView.isScrollEnabled = false
            pendingMembersTableView.isScrollEnabled = false

            let nib = UINib(nibName: "TeammateStatusCell", bundle: nil)
            acceptedMembersTableView.register(nib, forCellReuseIdentifier: "TeammateStatusCell")
            pendingMembersTableView.register(nib, forCellReuseIdentifier: "TeammateStatusCell")
        }

        private func loadInitialData() {
            loadTeamMembers()
            updateLimitsLabel()
        }

        // MARK: - Data Loading
        private func loadTeamMembers() {
            guard let validTeamID = teamID else {
                print("❌ Team ID missing")
                return
            }

            Task {
                do {
                    let allMembers = try await TeamService.shared.fetchTeamMembers(for: validTeamID)

                    acceptedMembers = allMembers.filter { $0.status == "accepted" }
                    pendingMembers  = allMembers.filter { $0.status == "pending" }

                    DispatchQueue.main.async {
                        self.acceptedMembersTableView.reloadData()
                        self.pendingMembersTableView.reloadData()
                        self.updateTableViewHeights()
                    }

                } catch {
                    print("❌ Failed to load team members: \(error)")
                }
            }
        }

        private func updateLimitsLabel() {
            guard let validTeamID = teamID else { return }

            Task {
                do {
                    let (min, max) = try await TeamService.shared.fetchTeamLimits(teamId: validTeamID)

                    DispatchQueue.main.async {
                        if max > 0 {
                            self.TeamLimitsLabel.text = "This event requires \(min)-\(max) members."
                        } else {
                            self.TeamLimitsLabel.text = "Team requirements unavailable."
                        }
                    }

                } catch {
                    print("❌ Failed to fetch team limits: \(error)")
                }
            }
        }

        // MARK: - Layout (THIS FIXES YOUR ERROR)
        private func updateTableViewHeights() {
            acceptedMembersTableView.layoutIfNeeded()
            pendingMembersTableView.layoutIfNeeded()

            acceptedTableHeight.constant = acceptedMembersTableView.contentSize.height
            pendingTableHeight.constant  = pendingMembersTableView.contentSize.height

            view.layoutIfNeeded()
        }

        // MARK: - Actions
        @IBAction func confirmTeamTapped(_ sender: UIButton) {
            handleConfirmTeam()
        }

        private func handleConfirmTeam() {
            guard let validTeamID = teamID else { return }

            if acceptedMembers.isEmpty {
                showErrorAlert(message: "You cannot register an empty team.")
                return
            }

            Task {
                do {
                    let result = try await TeamService.shared.confirmTeamRegistration(teamId: validTeamID)

                    DispatchQueue.main.async {
                        if result == "success" {
                            self.dismiss(animated: true)
                        } else {
                            self.showErrorAlert(message: self.readableError(from: result))
                        }
                    }

                } catch {
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: "Could not connect to the server. Please try again.")
                    }
                }
            }
        }

        // MARK: - Helpers
        private func readableError(from code: String) -> String {
            switch code {
            case "team_too_small":
                return "Your team does not meet the minimum size requirement."
            case "team_is_full":
                return "Your team has reached the maximum number of members."
            default:
                return "Something went wrong. Please try again."
            }
        }

        private func showErrorAlert(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    
}


extension ManageTeamModal: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView == acceptedMembersTableView
            ? acceptedMembers.count
            : pendingMembers.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "TeammateStatusCell",
            for: indexPath
        ) as? TeammateStatusCell else {
            return UITableViewCell()
        }

        let member = tableView == acceptedMembersTableView
            ? acceptedMembers[indexPath.row]
            : pendingMembers[indexPath.row]

        cell.configure(with: member)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}
