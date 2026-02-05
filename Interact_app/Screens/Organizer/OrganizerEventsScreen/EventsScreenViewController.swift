//
//  EventsScreenViewController.swift
//  Interact-UIKit
//
//  Created by admin73 on 07/11/25.
//

//import UIKit
//import Foundation
//import CoreData
//
//class EventsScreenViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
//
//
//    @IBOutlet weak var searchBar: UISearchBar!
//   
//    @IBOutlet weak var segmentedControl: UISegmentedControl!
//       
//    @IBOutlet weak var collectionView: UICollectionView!
//    
//    
//    @IBOutlet weak var fallbackView: FallBackView!
//    
//    
//    // MARK: - Properties
//        private var allEvents: [UserEvent] = []
//        private var filteredEvents: [UserEvent] = []
//        private var currentSegmentIndex: Int = 0
//        
//        // MARK: - Event Status
//        enum EventStatus {
//            case pending
//            case upcoming
//            case past
//        }
//
//        // MARK: - Lifecycle
//        override func viewDidLoad() {
//            super.viewDidLoad()
//            setupGradientBackground()
//            setupCollectionView()
//            setupSegmentedControl()
//            searchBar.delegate = self
//            addApproveAllButton() 
//            loadEventsFromCoreData()
//        }
//        
//        override func viewWillAppear(_ animated: Bool) {
//            super.viewWillAppear(animated)
//            loadEventsFromCoreData() // Refresh when view appears
//        }
//        
//        override func viewDidLayoutSubviews() {
//            super.viewDidLayoutSubviews()
//            view.layer.sublayers?.first?.frame = view.bounds
//        }
//
//        // MARK: - Core Data
//        private func loadEventsFromCoreData() {
//            allEvents = CoreDataManager.shared.fetchAllEvents()
//            printAllEvents()
//            applyFilters()
//        }
//
//
//        // MARK: - UI Setup
//        private func setupGradientBackground() {
//            let gradientLayer = CAGradientLayer()
//            gradientLayer.colors = [
//                UIColor.systemBlue.withAlphaComponent(0.2).cgColor,
//                UIColor.white.cgColor
//            ]
//            gradientLayer.locations = [0.0, 0.25]
//            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
//            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
//            gradientLayer.frame = view.bounds
//            view.layer.insertSublayer(gradientLayer, at: 0)
//        }
//
//        private func setupCollectionView() {
//            let nib = UINib(nibName: "EventCardCell", bundle: nil)
//            collectionView.register(nib, forCellWithReuseIdentifier: "EventCardCell")
//            collectionView.dataSource = self
//            collectionView.delegate = self
//            collectionView.backgroundColor = .clear
//        }
//
//        private func setupSegmentedControl() {
//            segmentedControl.removeAllSegments()
//            let segments = ["All", "Upcoming", "Pending", "Past"]
//            for (index, title) in segments.enumerated() {
//                segmentedControl.insertSegment(withTitle: title, at: index, animated: false)
//            }
//            segmentedControl.selectedSegmentIndex = 0
//            segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
//        }
//
//        // MARK: - Admin Approval System
//        private func addApproveAllButton() {
//            let approveButton = UIButton(type: .system)
//            approveButton.setTitle("Approve All", for: .normal)
//            approveButton.backgroundColor = .systemGreen
//            approveButton.setTitleColor(.white, for: .normal)
//            approveButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
//            approveButton.layer.cornerRadius = 6
//            approveButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//            approveButton.addTarget(self, action: #selector(approveAllPending), for: .touchUpInside)
//            
//            // Add as right bar button item
//            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: approveButton)
//        }
//        
//        @objc private func approveAllPending() {
//            let pendingEvents = allEvents.filter { !$0.isApproved }
//            
//            if pendingEvents.isEmpty {
//                showAlert(title: "No Pending Events", message: "All events are already approved!")
//                return
//            }
//            
//            for event in pendingEvents {
//                event.isApproved = true
//                print(" Approved: \(event.eventName ?? "Unnamed")")
//            }
//            
//            CoreDataManager.shared.saveContext()
//            loadEventsFromCoreData() // Refresh the view
//            
//            showAlert(title: "Success", message: "Approved \(pendingEvents.count) pending events")
//        }
//        
//        private func printAllEvents() {
//            let AllEvents = allEvents
//            
//            print("ALL EVENTS (\(AllEvents.count)):")
//            
//            for (index, event) in AllEvents.enumerated() {
//                print("""
//                Event #\(index + 1)
//                ID: \(event.id?.uuidString ?? "N/A")
//                Name: \(event.eventName ?? "Unnamed")
//                Location: \(event.location ?? "No location")
//                Team Size: \(event.teamSize)
//                Reg Count: \(event.registeredCount)
//                Start: \(event.startDate?.description ?? "No date")
//                isApproved: \(event.isApproved)
//                """)
//            }
//        }
//        
//        private func showAlert(title: String, message: String) {
//            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            present(alert, animated: true)
//        }
//
//        // MARK: - Filter Logic
//        @objc func segmentChanged(_ sender: UISegmentedControl) {
//            currentSegmentIndex = sender.selectedSegmentIndex
//            applyFilters()
//        }
//
//        func applyFilters(searchText: String = "") {
//            var filtered = allEvents
//            
//            switch currentSegmentIndex {
//            case 1: // Upcoming - Only approved events that haven't ended
//                filtered = filtered.filter {
//                    $0.isApproved &&
//                    ($0.endDate ?? Date()) > Date()
//                }
//            case 2: // Pending - Not approved yet
//                filtered = filtered.filter { !$0.isApproved }
//            case 3: // Past - Approved events that have ended
//                filtered = filtered.filter {
//                    $0.isApproved &&
//                    ($0.endDate ?? Date()) <= Date()
//                }
//            default: // All - Show everything
//                break
//            }
//            
//            // Apply search filter
//            if !searchText.isEmpty {
//                filtered = filtered.filter {
//                    ($0.eventName?.lowercased().contains(searchText.lowercased()) ?? false) ||
//                    ($0.location?.lowercased().contains(searchText.lowercased()) ?? false) ||
//                    ($0.eventDescription?.lowercased().contains(searchText.lowercased()) ?? false)
//                }
//            }
//            
//            filteredEvents = filtered
//            collectionView.reloadData()
//            
//            // Show/hide fallback based on empty state
//            fallbackView.isHidden = !filteredEvents.isEmpty
//            collectionView.isHidden = filteredEvents.isEmpty
//
//            // Update fallback message for each segment
//            if filteredEvents.isEmpty {
//                updateFallbackMessage()
//            }
//            
//            // Debug print
//            print("Filtered events: \(filteredEvents.count)")
////            filteredEvents.forEach { event in
////                print("   - \(event.eventName ?? "Unnamed"): \(getEventStatusString(for: event))")
////            }
//        }
//    
//    private func updateFallbackMessage() {
//        switch currentSegmentIndex {
//        case 1: // Upcoming
//            fallbackView.configure(message: "No upcoming events", showButton: true)
//            fallbackView.onCreateEventTapped = { [weak self] in
//                self?.showCreateEventModal()
//            }
//        case 2: // Pending
//            fallbackView.configure(message: "No pending events awaiting approval")
//        case 3: // Past
//            fallbackView.configure(message: "No past events")
//        default: // All
//            fallbackView.configure(message: "No events found")
//        }
//    }
//    
//    private func showCreateEventModal() {
//        let createEventVC = CreateEventViewController(nibName: "CreateEventViewController", bundle: nil)
//        createEventVC.modalPresentationStyle = .pageSheet
//        
//        if let sheet = createEventVC.sheetPresentationController {
//            sheet.detents = [.medium(), .large()]
//            sheet.prefersGrabberVisible = true
//            sheet.preferredCornerRadius = 20
//        }
//        
//        present(createEventVC, animated: true)
//    }
//
//        // MARK: - Collection View Data Source
//        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//            return filteredEvents.count
//        }
//
//        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCardCell", for: indexPath) as? EventCardCell else {
//                return UICollectionViewCell()
//            }
//            
//            let event = filteredEvents[indexPath.item]
//            configureCell(cell, with: event)
//            return cell
//        }
//        
//        private func configureCell(_ cell: EventCardCell, with event: UserEvent) {
//            // Set basic info
//            cell.titleLabel.text = event.eventName ?? "Unnamed Event"
//            cell.venueLabel.text = event.location ?? "No location"
//            
//            // Set date information
//            if let startDate = event.startDate, let endDate = event.endDate {
//                let dateString = formatEventDates(startDate: startDate, endDate: endDate)
//                cell.dateLabel.text = dateString
//            } else {
//                cell.dateLabel.text = "Date not set"
//            }
//            
//            // Set image
//            if let imageData = event.posterImageData, let image = UIImage(data: imageData) {
//                cell.eventImageView.image = image
//            } else {
//                cell.eventImageView.image = UIImage(named: "events") ?? UIImage(systemName: "photo")
//            }
//            
//            // Set status badge
////            let status = getEventStatusString(for: event)
////            let statusColor = getStatusColor(for: event)
////            cell.configureStatusBadge(text: status, color: statusColor)
//            
//            // Configure share button
//            cell.shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
//            
//            // Set up share action
//            // cell.shareButtonAction = { [weak self] in
//            //     self?.shareEvent(event)
//            // }
//        }
//        
//        private func formatEventDates(startDate: Date, endDate: Date) -> String {
//            let dateFormatter = DateFormatter()
//            
//            // If same day, show: "Nov 15, 2024 · 9:00 AM - 5:00 PM"
//            if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
//                dateFormatter.dateFormat = "E, d MMM yyyy"
//                let dateString = dateFormatter.string(from: startDate)
//                
//                dateFormatter.dateFormat = "h:mm a"
//                let startTime = dateFormatter.string(from: startDate)
//                let endTime = dateFormatter.string(from: endDate)
//                
//                return "\(dateString) · \(startTime) - \(endTime)"
//            } else {
//                // Different days: "Nov 15-16, 2024"
//                dateFormatter.dateFormat = "MMM d"
//                let startDay = dateFormatter.string(from: startDate)
//                let endDay = dateFormatter.string(from: endDate)
//                
//                dateFormatter.dateFormat = "yyyy"
//                let year = dateFormatter.string(from: startDate)
//                
//                return "\(startDay) - \(endDay), \(year)"
//            }
//        }
//        
//        private func shareEvent(_ event: UserEvent) {
//            let eventName = event.eventName ?? "Unnamed Event"
//            let location = event.location ?? "No location"
//            let description = event.eventDescription ?? "No description"
//            
//            let shareText = """
//            Check out this event: \(eventName)
//            
//            Location: \(location)
//            Description: \(description)
//            
//            Shared via Interact App
//            """
//            
//            let activityViewController = UIActivityViewController(
//                activityItems: [shareText],
//                applicationActivities: nil
//            )
//            
//            // For iPad
//            if let popoverController = activityViewController.popoverPresentationController {
//                popoverController.sourceView = self.view
//                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
//                popoverController.permittedArrowDirections = []
//            }
//            
//            present(activityViewController, animated: true)
//        }
//
//        // MARK: - Collection View Layout
//        func collectionView(_ collectionView: UICollectionView,
//                            layout collectionViewLayout: UICollectionViewLayout,
//                            sizeForItemAt indexPath: IndexPath) -> CGSize {
//            let horizontalInset: CGFloat = 16
//            let availableWidth = collectionView.frame.width - (horizontalInset * 2)
//            let aspectRatio: CGFloat = 200 / 320
//            var height = availableWidth * aspectRatio
//            let maxHeight: CGFloat = 230
//            let minHeight: CGFloat = 180
//            height = min(maxHeight, max(minHeight, height))
//            return CGSize(width: availableWidth, height: height)
//        }
//
//        func collectionView(_ collectionView: UICollectionView,
//                            layout collectionViewLayout: UICollectionViewLayout,
//                            insetForSectionAt section: Int) -> UIEdgeInsets {
//            UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
//        }
//
//        func collectionView(_ collectionView: UICollectionView,
//                            layout collectionViewLayout: UICollectionViewLayout,
//                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//            10
//        }
//
//        // MARK: - Search
//        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//            applyFilters(searchText: searchText)
//        }
//
//        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//            searchBar.resignFirstResponder()
//        }
//
//        // MARK: - Navigation
//        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//            let selectedEvent = filteredEvents[indexPath.item]
//            showEventDetails(event: selectedEvent)
//        }
//        
//        private func showEventDetails(event: UserEvent) {
//            let detailVC = EventDetailViewController()
//            detailVC.event = event
//            detailVC.hidesBottomBarWhenPushed = true
//            navigationController?.pushViewController(detailVC, animated: true)
//        }
//
//}

//
//  ParticipantEventsViewController.swift
//  Interact_app
//
//  Created by admin56 on 17/11/25.
//

import UIKit

class EventsScreenViewController: UIViewController {

//    @IBOutlet var containerView: UIView!
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
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
    
        enum EventSegment {
           case upcoming
           case pending
        }

        private var selectedSegment: EventSegment = .upcoming

        
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
            
//            setupUI()
            setupSearchBar()
            setupCollectionView()
            
            // 2. Fetch Initial Data
            fetchEvents()
        
            setupSegmentedControl()

        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            // Ensure filtered list stays in sync if search was cancelled elsewhere
            if !isSearching {
                filteredEvents = events
                collectionView.reloadData()
            }
        }
    
    private func setupSegmentedControl() {
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "Upcoming", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Pending", at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        
        segmentedControl.addTarget(
            self,
            action: #selector(segmentChanged(_:)),
            for: .valueChanged
        )
    }

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        selectedSegment = sender.selectedSegmentIndex == 0 ? .upcoming : .pending
        fetchEvents()
    }

    
    // MARK: - Network Calls (Debug Version)
    @objc private func fetchEvents() {
        print("🔵 Fetching events for segment:", selectedSegment)
        
        Task {
            do {
                let fetchedEvents: [Event]
                
                switch selectedSegment {
                case .upcoming:
                    fetchedEvents = try await EventService.shared.fetchUpcomingEvents()
                    
                case .pending:
                    fetchedEvents = try await EventService.shared.fetchPendingEvents()
                }
                
                print("🟢 API Success! Fetched \(fetchedEvents.count) events.")
                
                // Map to ViewModel
                self.events = fetchedEvents.map {
                    EventViewModel(eventData: $0, isRegistered: false)
                }
                
                DispatchQueue.main.async {
                    self.filteredEvents = self.events
                    self.collectionView.reloadData()
                    self.refreshControl.endRefreshing()
                }
                
            } catch {
                print("❌ Error fetching events:", error)
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
    extension EventsScreenViewController: UICollectionViewDataSource {
        
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
    extension EventsScreenViewController: UICollectionViewDelegateFlowLayout {
        
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
                detailVC.mode = .organizer
                detailVC.hidesBottomBarWhenPushed = true
                // 4. Push
                self.navigationController?.pushViewController(detailVC, animated: true)
            }    }

    // MARK: - UISearchBarDelegate
    extension EventsScreenViewController: UISearchBarDelegate {
        
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
