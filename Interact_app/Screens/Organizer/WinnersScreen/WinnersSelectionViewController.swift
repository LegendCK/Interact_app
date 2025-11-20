//
//  WinnersSelectionViewController.swift
//  Interact_app
//
//  Created by admin73 on 20/11/25.
//

import UIKit
import CoreData

class WinnersSelectionViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var emptyStateView: UIView!
    
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    // MARK: - Properties
    var event: UserEvent!
    private var teams: [Team] = []
    private var selectedTeams: [Int: Team] = [:]
    private var filteredTeams: [Team] = []
    private var publishButton: UIBarButtonItem!
    private var isSearching = false
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Initialization
    init(event: UserEvent) {
        self.event = event
        super.init(nibName: "WinnersSelectionViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadTeams()
        setupEmptyState()
        setupSearchController()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search teams by name"
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // Register cell
        let nib = UINib(nibName: "TeamCardCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "TeamCardCell")
        
        // Collection view setup
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemGroupedBackground
        
        // Configure layout
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 12
            layout.minimumInteritemSpacing = 12
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
    }
    
    private func setupEmptyState() {
        emptyStateLabel.text = "No teams available"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
    }
    
    private func loadTeams() {
        guard let eventId = event.id else { return }
        teams = CoreDataManager.shared.getTeams(for: eventId)
        filteredTeams = teams
        collectionView.reloadData()
        updateEmptyState()
        updateNavigationSubtitle()
    }
    
    private func updateEmptyState() {
        let hasData = isSearching ? !filteredTeams.isEmpty : !teams.isEmpty
        emptyStateView.isHidden = hasData
        
        if isSearching && filteredTeams.isEmpty && !searchController.searchBar.text!.isEmpty {
            emptyStateLabel.text = "No teams found for \"\(searchController.searchBar.text!)\""
        } else {
            emptyStateLabel.text = "No teams available"
        }
    }
    
    private func filterTeams(for searchText: String) {
        if searchText.isEmpty {
            filteredTeams = teams
        } else {
            filteredTeams = teams.filter { team in
                guard let teamName = team.teamName else { return false }
                return teamName.lowercased().contains(searchText.lowercased())
            }
        }
        collectionView.reloadData()
        updateEmptyState()
    }
    
    private func setupNavigationBar() {
        title = "Announce Winners"
        
        publishButton = UIBarButtonItem(
            title: "Publish",
            style: .done,
            target: self,
            action: #selector(publishTapped)
        )
        publishButton.isEnabled = false
        navigationItem.rightBarButtonItem = publishButton
        
        updateNavigationSubtitle()
    }
    
    private func updateNavigationSubtitle() {
        guard isViewLoaded else { return }
        
        let selectedCount = selectedTeams.count
        let subtitleText: String
        
        switch selectedCount {
        case 0:
            subtitleText = "Select First Prize Winner"
        case 1:
            subtitleText = "Select Second Prize Winner"
        case 2:
            subtitleText = "Select Third Prize Winner"
        case 3:
            subtitleText = "All Winners Selected"
        default:
            subtitleText = "Announce Winners"
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "Announce Winners"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitleText
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textColor = .systemGray
        subtitleLabel.textAlignment = .center
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        
        navigationItem.titleView = stackView
        
        publishButton?.isEnabled = selectedCount == 3
    }
    
    // MARK: - Selection Logic
    private func getPrizeRank(for team: Team) -> Int {
        for (rank, selectedTeam) in selectedTeams {
            if selectedTeam.id == team.id {
                return rank
            }
        }
        return 0
    }
    
    private func handleTeamSelection(_ team: Team) {
        let currentRank = getPrizeRank(for: team)
        
        if currentRank > 0 {
            // Deselect - remove from selected teams
            selectedTeams.removeValue(forKey: currentRank)
            print("Deselected: \(team.teamName ?? "") from rank \(currentRank)")
        } else {
            // Select - assign next available rank
            let nextRank = selectedTeams.count + 1
            if nextRank <= 3 {
                selectedTeams[nextRank] = team
                print("Selected: \(team.teamName ?? "") as rank \(nextRank)")
            } else {
                showMaxSelectionAlert()
                return
            }
        }
        
        updateUIAfterSelection()
    }
    
    private func updateUIAfterSelection() {
        collectionView.reloadData()
        updateNavigationSubtitle()
    }
    
    private func showMaxSelectionAlert() {
        let alert = UIAlertController(
            title: "Maximum Winners Reached",
            message: "You can only select 3 winners. Deselect a winner first to select a different team.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Publish Action
    @objc private func publishTapped() {
        showPublishConfirmation()
    }
    
    private func showPublishConfirmation() {
        let alert = UIAlertController(
            title: "Publish Winners",
            message: "Are you sure you want to publish these winners? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Publish", style: .default, handler: { [weak self] _ in
            self?.publishWinners()
        }))
        
        present(alert, animated: true)
    }
    
    private func publishWinners() {
        guard let eventId = event.id else { return }
        
        // Convert selectedTeams to [UUID: Int16] for CoreData
        var winners: [UUID: Int16] = [:]
        for (rank, team) in selectedTeams {
            if let teamId = team.id {
                winners[teamId] = Int16(rank)
            }
        }
        
        let success = CoreDataManager.shared.publishWinners(for: eventId, winners: winners)
        
        if success {
            showSuccessAlert()
        } else {
            showErrorAlert()
        }
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Winners Published!",
            message: "The winners have been successfully announced for this event.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Publication Failed",
            message: "There was an error publishing the winners. Please try again.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension WinnersSelectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredTeams.count : teams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TeamCardCell", for: indexPath) as! TeamCardCell
        
        let team = isSearching ? filteredTeams[indexPath.item] : teams[indexPath.item]
        let prizeRank = getPrizeRank(for: team)
        
        cell.configure(with: team, prizeRank: prizeRank)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let team = isSearching ? filteredTeams[indexPath.item] : teams[indexPath.item]
        handleTeamSelection(team)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let collectionViewWidth = collectionView.frame.width - (padding * 2)
        return CGSize(width: collectionViewWidth, height: 100) 
    }
}

// MARK: - UISearchResultsUpdating
extension WinnersSelectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        isSearching = !searchText.isEmpty
        filterTeams(for: searchText)
    }
}

// MARK: - UISearchBarDelegate
extension WinnersSelectionViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        filteredTeams = teams
        collectionView.reloadData()
        updateEmptyState()
    }
}
