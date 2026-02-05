//
//  RSVPViewController.swift
//  Interact-UIKit
//
//  Created by admin73 on 18/11/25.
//

import UIKit
import CoreData

class RSVPViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var emptyStateView: UIView!
    
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    @IBOutlet weak var statsView: UIView!
    
    @IBOutlet weak var statsLabel: UILabel!
    
    // MARK: - Properties
        var eventId: UUID!

        private var participants: [EventParticipant] = []
        private var filteredParticipants: [EventParticipant] = []
        private var isSearching = false
        private let searchController = UISearchController(searchResultsController: nil)

        // MARK: - Init
        init(eventId: UUID) {
            self.eventId = eventId
            super.init(nibName: "RSVPViewController", bundle: nil)
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupCollectionView()
            setupNavigationBar()
            setupEmptyState()
            setupSearchController()
            loadParticipants()
        }

        // MARK: - Setup
        private func setupNavigationBar() {
            title = "Attendance & Food"
        }

        private func setupEmptyState() {
            emptyStateLabel.text = "No participants to manage"
            emptyStateLabel.textAlignment = .center
            emptyStateLabel.numberOfLines = 0
        }

        private func setupSearchController() {
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Search participants by name"
            searchController.searchBar.delegate = self

            navigationItem.searchController = searchController
            definesPresentationContext = true
            navigationItem.hidesSearchBarWhenScrolling = false
        }

        private func setupCollectionView() {
            collectionView.delegate = self
            collectionView.dataSource = self

            let nib = UINib(nibName: "RSVPCell", bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: "RSVPCell")

            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .vertical
                layout.minimumLineSpacing = 12
                layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            }

            collectionView.backgroundColor = UIColor(hex: "#007AFF").withAlphaComponent(0.1)
        }

        // MARK: - Data
        private func loadParticipants() {
            guard let eventId = eventId else { return }

            Task {
                do {
                    let fetched = try await RegistrationService.shared.fetchEventParticipants(eventId: eventId)

                    DispatchQueue.main.async {
                        self.participants = fetched
                        self.filteredParticipants = fetched
                        self.collectionView.reloadData()
                        self.updateEmptyState()
                        self.updateStats()
                    }

                } catch {
                    print("❌ Failed to fetch RSVP participants:", error)
                }
            }
        }

        private func filterParticipants(for searchText: String) {
            if searchText.isEmpty {
                filteredParticipants = participants
            } else {
                filteredParticipants = participants.filter {
                    $0.name.lowercased().contains(searchText.lowercased())
                }
            }
            collectionView.reloadData()
            updateEmptyState()
            updateStats()
        }

        // MARK: - Stats
        private func updateStats() {
            let total = participants.count
            let attended = participants.filter { $0.status == "attended" }.count
            let foodTaken = participants.filter { $0.status == "food_taken" }.count

            statsLabel.text = "Present: \(attended)/\(total) • Food: \(foodTaken)"
            statsLabel.textAlignment = .center
            statsLabel.font = .systemFont(ofSize: 16, weight: .medium)
            statsView.backgroundColor = UIColor(hex: "#D1DCEF")
        }

        private func updateEmptyState() {
            let hasData = isSearching ? !filteredParticipants.isEmpty : !participants.isEmpty
            emptyStateView.isHidden = hasData

            if isSearching, filteredParticipants.isEmpty {
                emptyStateLabel.text = "No participants found"
            } else {
                emptyStateLabel.text = "No participants to manage"
            }
        }
}

extension RSVPViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        isSearching ? filteredParticipants.count : participants.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "RSVPCell",
            for: indexPath
        ) as! RSVPCell

        let participant = isSearching
            ? filteredParticipants[indexPath.item]
            : participants[indexPath.item]

        cell.configure(
            name: participant.name,
            teamName: participant.teamName,
            email: participant.email,
            isAttended: participant.status == "attended",
            hasFood: participant.status == "food_taken",
            checkedInAt: participant.joinedAt,
            rsvpForFood: true
        )



        // TODO: Replace with RPC calls later
        cell.onAttendanceTapped = { isAttended in
            print("Attendance toggled:", participant.userId, isAttended)
        }

        cell.onFoodTapped = { hasFood in
            print("Food toggled:", participant.userId, hasFood)
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.frame.width - 32
        return CGSize(width: width, height: 120)
    }
}

extension RSVPViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        isSearching = !text.isEmpty
        filterParticipants(for: text)
    }
}

extension RSVPViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        filteredParticipants = participants
        collectionView.reloadData()
        updateEmptyState()
        updateStats()
    }
}

