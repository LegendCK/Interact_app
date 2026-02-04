//
//  NotificationsViewController.swift
//  Interact_app
//
//  Created by admin73 on 18/01/26.
//

import UIKit

class NotificationsViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
        
        // Data Sources
        private var connectionRequests: [ConnectionRequest] = []
        private var teamInvites: [TeamInviteDisplay] = []
        
        private let refreshControl = UIRefreshControl()
        
        // Helper to determine active tab
        private var isConnectionSegment: Bool {
            return segmentedControl.selectedSegmentIndex == 0
        }
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupCollectionView()
            setupSegmentedControl()
            
            // Initial Fetch
            fetchData()
        }
        
        // MARK: - Setup
        private func setupCollectionView() {
            collectionView.delegate = self
            collectionView.dataSource = self
            
            // 1. Register Connection Card XIB
            let connNib = UINib(nibName: "ConnectionInvitesCard", bundle: nil)
            collectionView.register(connNib, forCellWithReuseIdentifier: "ConnectionInvitesCard")
            
            // 2. Register Team Invite Card XIB
            // Ensure your XIB file name matches "TeamInvitesCard" exactly
            let teamNib = UINib(nibName: "TeamInvitesCard", bundle: nil)
            collectionView.register(teamNib, forCellWithReuseIdentifier: "TeamInvitesCard")
            
            // Styling
            collectionView.backgroundColor = UIColor(hex: "#007AFF").withAlphaComponent(0.1)
            collectionView.layer.cornerRadius = 16
            collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            collectionView.layer.masksToBounds = true
            
            // Add Pull-to-Refresh
            refreshControl.addTarget(self, action: #selector(fetchData), for: .valueChanged)
            collectionView.refreshControl = refreshControl
            
            // Layout Config
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                let width = UIScreen.main.bounds.width - 32 // 16pt padding on sides
                // Adjusted height to accommodate extra labels in Team Card (Lead + Event Name)
                layout.itemSize = CGSize(width: width, height: 140)
                layout.minimumLineSpacing = 10
                layout.sectionInset = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
            }
        }
        
        private func setupSegmentedControl() {
            segmentedControl.setTitle("Connections", forSegmentAt: 0)
            segmentedControl.setTitle("Team Invites", forSegmentAt: 1)
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        }
        
        // MARK: - Actions
        @objc private func segmentChanged(_ sender: UISegmentedControl) {
            // 1. Reload the list immediately so rows disappear/appear
            collectionView.reloadData()
            
            // 2. FORCE update the background text ("No connections" vs "No teams")
            updateEmptyState()
            
            // 3. Trigger a fetch if switching to a tab that is empty
            if !isConnectionSegment && teamInvites.isEmpty {
                 fetchData()
            } else if isConnectionSegment && connectionRequests.isEmpty {
                 fetchData()
            }
        }
        
        @objc private func fetchData() {
            Task {
                do {
                    if isConnectionSegment {
                        // Fetch Connection Requests
                        connectionRequests = try await ConnectionService.shared.fetchPendingRequests()
                    } else {
                        // Fetch Team Invites
                        teamInvites = try await TeamService.shared.fetchPendingInvites()
                    }
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.refreshControl.endRefreshing()
                        self.updateEmptyState()
                    }
                } catch {
                    print("Error fetching notifications: \(error)")
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        }
        
        private func updateEmptyState() {
            let isEmpty = isConnectionSegment ? connectionRequests.isEmpty : teamInvites.isEmpty
            
            if isEmpty {
                let label = UILabel()
                label.text = isConnectionSegment ? "No pending connection requests" : "No pending team invites"
                label.textAlignment = .center
                label.textColor = .secondaryLabel
                label.numberOfLines = 0
                collectionView.backgroundView = label
            } else {
                collectionView.backgroundView = nil
            }
        }
}

// MARK: - CollectionView DataSource & Delegate
extension NotificationsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isConnectionSegment ? connectionRequests.count : teamInvites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isConnectionSegment {
            // MARK: 1. Connection Card
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConnectionInvitesCard", for: indexPath) as? ConnectionInvitesCard else {
                return UICollectionViewCell()
            }
            
            let request = connectionRequests[indexPath.item]
            
            // Configure Cell
            cell.configure(with: request)
            
            // Handle Action Closure
            cell.didTapDecision = { [weak self] accepted in
                self?.handleConnectionDecision(request: request, accepted: accepted, index: indexPath)
            }
            
            return cell
            
        } else {
            // MARK: 2. Team Invite Card
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TeamInvitesCard", for: indexPath) as? TeamInvitesCard else {
                return UICollectionViewCell()
            }
            
            let invite = teamInvites[indexPath.item]
            
            // Configure Cell
            cell.configure(with: invite)
            
            // Handle Action Closure
            cell.didTapDecision = { [weak self] accepted in
                self?.handleTeamDecision(invite: invite, accepted: accepted, index: indexPath)
            }
            
            return cell
        }
    }
    
    // MARK: - Logic Implementation (Connections)
    private func handleConnectionDecision(request: ConnectionRequest, accepted: Bool, index: IndexPath) {
        // 1. Optimistic Update (Remove from UI immediately)
        connectionRequests.remove(at: index.item)
        collectionView.deleteItems(at: [index])
        updateEmptyState()
        
        // 2. Call Backend
        Task {
            do {
                if accepted {
                    try await ConnectionService.shared.acceptConnectionRequest(connectionId: request.id)
                    print("✅ Accepted connection from \(request.sender.fullName)")
                } else {
                    try await ConnectionService.shared.rejectConnectionRequest(connectionId: request.id)
                    print("❌ Rejected connection from \(request.sender.fullName)")
                }
            } catch {
                print("Failed to update connection status: \(error)")
                // Optional: Re-fetch or show alert if it fails
            }
        }
    }
    
    // MARK: - Logic Implementation (Teams)
    private func handleTeamDecision(
        invite: TeamInviteDisplay,
        accepted: Bool,
        index: IndexPath
    ) {
        // 1️⃣ Optimistic UI update (SAFE)
        DispatchQueue.main.async {
            guard let currentIndex = self.teamInvites.firstIndex(where: {
                $0.teamId == invite.teamId
            }) else {
                return // Already removed / list refreshed
            }

            self.teamInvites.remove(at: currentIndex)

            self.collectionView.performBatchUpdates {
                self.collectionView.deleteItems(
                    at: [IndexPath(item: currentIndex, section: 0)]
                )
            }

            self.updateEmptyState()
        }

        // 2️⃣ Backend call
        Task {
            do {
                if accepted {
                    let result = try await TeamService.shared.acceptInvite(
                        teamId: invite.teamId
                    )

                    if result == "success" {
                        print("✅ Joined Team: \(invite.teamName)")
                        NotificationCenter.default.post(
                            name: NSNotification.Name("TeamJoined"),
                            object: nil
                        )

                    } else if result == "team_is_full" {
                        // 🔁 Rollback UI if optimistic update was wrong
                        DispatchQueue.main.async {
                            let alert = UIAlertController(
                                title: "Team Full",
                                message: "This team has already reached its maximum size.",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)

                            self.fetchData() // authoritative refresh
                        }
                        return
                    } else {
                        throw NSError(
                            domain: "App",
                            code: 0,
                            userInfo: [
                                NSLocalizedDescriptionKey:
                                    "Failed to accept invite: \(result)"
                            ]
                        )
                    }

                } else {
                    // ❌ DECLINE
                    try await TeamService.shared.declineInvite(
                        teamId: invite.teamId
                    )
                    print("❌ Declined invite for: \(invite.teamName)")
                }

                // ❌ DO NOT fetchData() here — UI already updated optimistically

            } catch {
                print("Failed to process invite: \(error)")

                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "Error",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)

                    // 🔁 Rollback on failure
                    self.fetchData()
                }
            }
        }
    }

}
