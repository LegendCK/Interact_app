//
//  ParticipantEventsViewController.swift
//  Interact_app
//
//  Created by admin56 on 17/11/25.
//

import UIKit

class ParticipantEventsViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    // MARK: - Local Models
        /// A view model to combine the raw API data with local state (like isRegistered)
        struct EventViewModel {
            let eventData: Event
            var isRegistered: Bool
        }
        
        // MARK: - Properties
        private var events: [EventViewModel] = []
        private var filteredEvents: [EventViewModel] = []
        private var isSearching: Bool = false
        private let refreshControl = UIRefreshControl()
        
        // MARK: - Lifecycle
    override func viewDidLoad() {
            super.viewDidLoad()
            
            // 1. Initialize Client (Safety Check)
            // Since keys are in xcconfig/Info.plist, we just initialize the config directly.
            if EventService.shared.client == nil {
                print("⚠️ Initializing Client locally in VC from Config.")
                
                do {
                    // FIXED: Removed the arguments.
                    // This calls 'init(bundle: .main)' which reads your Info.plist/xcconfig automatically.
                    let config = try SupabaseConfig()
                    
                    EventService.shared.client = SupabaseClient(config: config)
                    print("✅ Supabase Client initialized successfully.")
                    
                } catch {
                    print("❌ Failed to load Supabase Config: \(error)")
                    // Optional: Show an alert here if config fails
                }
            }
            
            setupUI()
            setupSearchBar()
            setupCollectionView()
            
            // 2. Fetch Initial Data
            fetchEvents()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            // Ensure filtered list stays in sync if search was cancelled elsewhere
            if !isSearching {
                filteredEvents = events
                collectionView.reloadData()
            }
        }

        // MARK: - Network Calls
//        @objc private func fetchEvents() {
//            // Show refreshing state if triggered manually or via pull-to-refresh
//            if !refreshControl.isRefreshing {
//                // Optional: Show a loading spinner here if you have one
//            }
//            
//            Task {
//                do {
//                    // 1. Call the Service
//                    let fetchedEvents = try await EventService.shared.fetchUpcomingEvents()
//                    
//                    // 2. Map API Model -> View Model
//                    // We default 'isRegistered' to false for now.
//                    // In a real app, you would also fetch a "registrations" table to check this.
//                    self.events = fetchedEvents.map { event in
//                        EventViewModel(eventData: event, isRegistered: false)
//                    }
//                    
//                    // 3. Update UI on Main Thread
//                    DispatchQueue.main.async {
//                        self.filteredEvents = self.events
//                        self.collectionView.reloadData()
//                        self.refreshControl.endRefreshing()
//                    }
//                } catch {
//                    print("❌ Error fetching events: \(error)")
//                    DispatchQueue.main.async {
//                        self.refreshControl.endRefreshing()
//                        self.showErrorAlert(message: error.localizedDescription)
//                    }
//                }
//            }
//        }
    
    // MARK: - Network Calls (Debug Version)
        @objc private func fetchEvents() {
            print("Attempting to fetch events...") // Debug 1
            
            if !refreshControl.isRefreshing {
                // Optional: Show spinner
            }
            
            Task {
                do {
                    // 1. Call the Service
                    let fetchedEvents = try await EventService.shared.fetchUpcomingEvents()
                    
                    print("API Success! Fetched \(fetchedEvents.count) events.") // Debug 2
                    
                    // 2. Map Data
                    self.events = fetchedEvents.map { event in
                        EventViewModel(eventData: event, isRegistered: false)
                    }
                    
                    // 3. Update UI
                    DispatchQueue.main.async {
                        self.filteredEvents = self.events
                        
                        print("Reloading CollectionView with \(self.filteredEvents.count) items.") // Debug 3
                        
                        self.collectionView.reloadData()
                        self.refreshControl.endRefreshing()
                        
                        // Debug 4: Check if view is actually visible
                        print("📏 CollectionView Frame: \(self.collectionView.frame)")
                    }
                } catch {
                    print("Error fetching events: \(error)")
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                        self.showErrorAlert(message: error.localizedDescription)
                    }
                }
            }
        }
 
        // MARK: - UI Setup
        private func setupUI() {
            // Set a subtle background color for the container
            containerView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        }

        private func setupSearchBar() {
            searchBar.delegate = self
            searchBar.placeholder = "Search events..."

                    // 1. Remove ALL UISearchBar background layers
            searchBar.searchBarStyle = .default
            searchBar.backgroundImage = UIImage()
            searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)

                    // 2. Remove the internal background view (THIS fixes the gray sides)
            if let backgroundView = searchBar.subviews.first?.subviews.first {
                backgroundView.alpha = 0
            }

                    // 3. Style the actual text field
            let textField = searchBar.searchTextField
            textField.backgroundColor = .white
            textField.layer.cornerRadius = 20
            textField.layer.masksToBounds = true

                    // 4. Ensure no clipping artifacts
            searchBar.clipsToBounds = false
        }

        private func setupCollectionView() {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundColor = .clear
            
            // Register the NIB
            let nib = UINib(nibName: "ParticipantEventCard", bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: "ParticipantEventCard")
            
            // Add Pull-to-Refresh
            refreshControl.addTarget(self, action: #selector(fetchEvents), for: .valueChanged)
            collectionView.refreshControl = refreshControl
            
            // Configure Layout
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.minimumLineSpacing = 20
                layout.minimumInteritemSpacing = 20
                layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 20, right: 16)
            }
        }
        
        // MARK: - Logic Helpers
        private func getEventsForDisplay() -> [EventViewModel] {
            return isSearching ? filteredEvents : events
        }
        
        private func showErrorAlert(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        
        // MARK: - Interaction Handlers
        private func toggleRegistration(for eventId: UUID?) {
            guard let id = eventId else { return }
            
            // 1. Update Main List
            if let index = events.firstIndex(where: { $0.eventData.id == id }) {
                events[index].isRegistered.toggle()
                
                // 2. Update Filtered List if needed
                if isSearching, let filteredIndex = filteredEvents.firstIndex(where: { $0.eventData.id == id }) {
                    filteredEvents[filteredIndex].isRegistered = events[index].isRegistered
                } else if !isSearching {
                    filteredEvents = events
                }
                
                // 3. Reload specific item for smooth animation
                // Find the index in the *displayed* list
                if let displayIndex = getEventsForDisplay().firstIndex(where: { $0.eventData.id == id }) {
                    let indexPath = IndexPath(item: displayIndex, section: 0)
                    collectionView.reloadItems(at: [indexPath])
                }
            }
            
            // NOTE: Here you would ideally make an API call to Supabase to insert/delete from 'registrations' table
            print("Toggled registration for event: \(id)")
        }
        
        private func shareEvent(_ eventId: UUID?) {
            guard let eventVM = getEventsForDisplay().first(where: { $0.eventData.id == eventId }) else { return }
            let event = eventVM.eventData
            
            let textToShare = "Join me at \(event.title)!\nDate: \(event.startDate.toEventString())\nLocation: \(event.location ?? "Online")"
            
            // Add URL if available
            var items: [Any] = [textToShare]
            if let link = event.meetingLink, let url = URL(string: link) {
                items.append(url)
            }
            
            let activityViewController = UIActivityViewController(
                activityItems: items,
                applicationActivities: nil
            )
            
            // iPad support
            if let popover = activityViewController.popoverPresentationController {
                popover.sourceView = self.view
                popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            present(activityViewController, animated: true, completion: nil)
        }
    }

    // MARK: - UICollectionView DataSource
    extension ParticipantEventsViewController: UICollectionViewDataSource {
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return getEventsForDisplay().count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ParticipantEventCard",
                for: indexPath
            ) as? ParticipantEventCard else {
                return UICollectionViewCell()
            }
            
            let vm = getEventsForDisplay()[indexPath.item]
            let event = vm.eventData
            
            // Create the Display Data struct required by the Cell
            let cellData = ParticipantEventCard.EventDisplayData(
                id: event.id,
                imageUrl: event.thumbnailUrl, // Maps API 'thumbnailUrl' to Cell 'imageUrl'
                title: event.title,
                date: event.startDate.toEventString(), // Uses your Date Extension
                location: event.locationType == .online ? "Online Event" : (event.location ?? "TBA"),
                isRegistered: vm.isRegistered
            )
            
            // Configure Cell
            cell.configure(with: cellData)
            
            // Handle Button Taps
            cell.onRegisterTap = { [weak self] eventId, _ in
                self?.toggleRegistration(for: eventId)
            }
            
            cell.onShareTap = { [weak self] eventId in
                self?.shareEvent(eventId)
            }
            
            return cell
        }
    }

    // MARK: - UICollectionView Delegate FlowLayout
    extension ParticipantEventsViewController: UICollectionViewDelegateFlowLayout {
        
        func collectionView(_ collectionView: UICollectionView,
                           layout collectionViewLayout: UICollectionViewLayout,
                           sizeForItemAt indexPath: IndexPath) -> CGSize {
            // Full width minus padding
            let padding: CGFloat = 32 // 16 left + 16 right
            let width = collectionView.frame.width - padding
            
            // Height estimation: Image (150) + Content (approx 135)
            return CGSize(width: width, height: 285)
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                // 1. Get the data
                let vm = getEventsForDisplay()[indexPath.item]
                let selectedEvent = vm.eventData
                
                // 2. Initialize VC from XIB
                // "ParticipantEventDetailViewController" must match your .xib filename exactly
                let detailVC = ParticipantEventDetailViewController(nibName: "ParticipantEventDetailViewController", bundle: nil)
                
                // 3. Pass Data
                detailVC.event = selectedEvent
                detailVC.hidesBottomBarWhenPushed = true
                // 4. Push
                self.navigationController?.pushViewController(detailVC, animated: true)
            }    }

    // MARK: - UISearchBarDelegate
    extension ParticipantEventsViewController: UISearchBarDelegate {
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.isEmpty {
                isSearching = false
                filteredEvents = events
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                }
            } else {
                isSearching = true
                filteredEvents = events.filter { vm in
                    let event = vm.eventData
                    let titleMatch = event.title.lowercased().contains(searchText.lowercased())
                    let locMatch = (event.location ?? "").lowercased().contains(searchText.lowercased())
                    return titleMatch || locMatch
                }
            }
            collectionView.reloadData()
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = ""
            isSearching = false
            filteredEvents = events
            collectionView.reloadData()
            searchBar.resignFirstResponder()
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
}
