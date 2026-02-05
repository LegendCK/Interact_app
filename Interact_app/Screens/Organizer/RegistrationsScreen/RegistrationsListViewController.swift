import UIKit


class RegistrationsListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    // MARK: - Properties
    var eventId: UUID!

    private var participants: [EventParticipant] = []
    private var filteredParticipants: [EventParticipant] = []

    private var isSearching = false
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Initialization (for XIB)
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
    
    init(eventId: UUID) {
        self.eventId = eventId
        super.init(nibName: "RegistrationsListViewController", bundle: nil)
    }

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadParticipants()
        setupNavigationBar()
        setupEmptyState()
        setupSearchController()
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search participants by name"
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func setupNavigationBar() {
        title = "Registrations (\(participants.count))"
    }
    
    private func setupEmptyState() {
        emptyStateLabel.text = "No registrations yet"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register custom participant cell
        let nib = UINib(nibName: "ParticipantCardCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ParticipantCardCell")
        
        // Configure layout
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 12
            layout.minimumInteritemSpacing = 12
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
        
        collectionView.backgroundColor = UIColor(hex: "#007AFF").withAlphaComponent(0.1)
        collectionView.layer.cornerRadius = 16
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collectionView.layer.masksToBounds = true

    }
    
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
                    self.setupNavigationBar()
                }

            } catch {
                print("❌ Failed to fetch participants:", error)
            }
        }
    }

    
    private func updateEmptyState() {
        let hasData = isSearching ? !filteredParticipants.isEmpty : !participants.isEmpty
        emptyStateView.isHidden = hasData
        
        if isSearching && filteredParticipants.isEmpty, let searchText = searchController.searchBar.text, !searchText.isEmpty {
            emptyStateLabel.text = "No participants found for \"\(searchText)\""
        } else {
            emptyStateLabel.text = "No registrations yet"
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
        setupNavigationBar() // Update count in title
    }

}

// MARK: - UICollectionView DataSource & Delegate
extension RegistrationsListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredParticipants.count : participants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParticipantCardCell", for: indexPath) as! ParticipantCardCell
        
        let participant = isSearching ? filteredParticipants[indexPath.item] : participants[indexPath.item]
        
        cell.configure(
            name: participant.name,
            teamName: participant.teamName,
            email: participant.email,
            joinedAt: participant.joinedAt
        )
        
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let collectionViewWidth = collectionView.frame.width - (padding * 2)
        return CGSize(width: collectionViewWidth, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let participant = isSearching ? filteredParticipants[indexPath.item] : participants[indexPath.item]
        print("Selected: \(participant.name)")

    }
}


// MARK: - UISearchResultsUpdating
extension RegistrationsListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        isSearching = !searchText.isEmpty
        filterParticipants(for: searchText)
    }
}

// MARK: - UISearchBarDelegate
extension RegistrationsListViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        filteredParticipants = participants
        collectionView.reloadData()
        updateEmptyState()
        setupNavigationBar()
    }
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchText.isEmpty {
//            isSearching = false
//            filteredParticipants = participants
//            collectionView.reloadData()
//            updateEmptyState()
//            setupNavigationBar()
//        }
//    }
}
