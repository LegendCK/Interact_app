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
    
    @IBOutlet weak var statsLabel: UILabel!
    
    // MARK: - Properties
    var event: UserEvent!
    private var participants: [Participant] = []
    private var filteredParticipants: [Participant] = []
    private var isSearching = false
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadParticipants()
        setupNavigationBar()
        setupEmptyState()
        updateStats()
        setupSearchController()
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
    
    private func setupNavigationBar() {
        title = "Attendance & Food"
    }
    
    private func setupEmptyState() {
        emptyStateLabel.text = "No participants to manage"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register custom RSVP cell
        let nib = UINib(nibName: "RSVPCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "RSVPCell")
        
        // Configure layout
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 12
            layout.minimumInteritemSpacing = 12
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
        
        collectionView.backgroundColor = .systemGroupedBackground
    }
    
    private func loadParticipants() {
        guard let eventId = event.id else { return }
        participants = CoreDataManager.shared.getParticipants(for: eventId)
        filteredParticipants = participants // Initialize filtered array
        collectionView.reloadData()
        updateEmptyState()
        updateStats()
    }
    
//    private func setupEmptyState() {
//        emptyStateLabel.text = "No participants to manage"
//        emptyStateLabel.textAlignment = .center
//        emptyStateLabel.numberOfLines = 0
//    }

    private func updateEmptyState() {
        let hasData = isSearching ? !filteredParticipants.isEmpty : !participants.isEmpty
        emptyStateView.isHidden = hasData
        
        if isSearching && filteredParticipants.isEmpty && !searchController.searchBar.text!.isEmpty {
            emptyStateLabel.text = "No participants found for \"\(searchController.searchBar.text!)\""
        } else {
            emptyStateLabel.text = "No participants to manage"
        }
    }
    
    private func filterParticipants(for searchText: String) {
        if searchText.isEmpty {
            filteredParticipants = participants
        } else {
            filteredParticipants = participants.filter { participant in
                guard let name = participant.name else { return false }
                return name.lowercased().contains(searchText.lowercased())
            }
        }
        collectionView.reloadData()
        updateEmptyState()
        updateStats()
    }
    
    private func updateStats() {
        guard let eventId = event.id else { return }
        let stats = CoreDataManager.shared.getAttendanceStats(for: eventId)
        
        statsLabel.text = "Present: \(stats.attended)/\(stats.total) • Food: \(stats.foodTaken)"
        statsLabel.textAlignment = .center
        statsLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension RSVPViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredParticipants.count : participants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RSVPCell", for: indexPath) as! RSVPCell
        
        let participant = isSearching ? filteredParticipants[indexPath.item] : participants[indexPath.item]
        cell.configure(
                with: participant,
                rsvpForFood: event.rsvpForFood
            )
        
        // Handle attendance toggle
        cell.onAttendanceTapped = { [weak self] isAttended in
            guard let self = self, let participantId = participant.id else { return }
            
            let success = CoreDataManager.shared.updateAttendance(
                participantId: participantId,
                isAttended: isAttended
            )
            
            if success {
                self.updateStats()
            }
        }
        
        // Handle food toggle
        cell.onFoodTapped = { [weak self] hasFood in
            guard let self = self, let participantId = participant.id else { return }
            
            let success = CoreDataManager.shared.updateFoodStatus(
                participantId: participantId,
                hasFood: hasFood
            )
            
            if success {
                self.updateStats()
            }
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let collectionViewWidth = collectionView.frame.width - (padding * 2)
        return CGSize(width: collectionViewWidth, height: 120)
    }
}

// MARK: - UISearchResultsUpdating
extension RSVPViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        isSearching = !searchText.isEmpty
        filterParticipants(for: searchText)
    }
}

// MARK: - UISearchBarDelegate
extension RSVPViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        filteredParticipants = participants
        collectionView.reloadData()
        updateEmptyState()
        updateStats()
    }
}
