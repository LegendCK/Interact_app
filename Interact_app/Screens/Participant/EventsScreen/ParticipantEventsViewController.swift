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
    
    
    // MARK: - Data Model 
    struct Event {
        let id: Int
        let imageName: String
        let title: String
        let startDate: String
        let endDate: String
        let location: String
        let isRegistered: Bool
    }
    
    // MARK: - Dummy Events Data (same as before)
    private var events: [Event] = [
        Event(
            id: 1,
            imageName: "events",
            title: "Tech Innovators Summit 2024",
            startDate: "Dec 15, 2024 • 9:00 AM",
            endDate: "Dec 17, 2024 • 5:00 PM",
            location: "Convention Center, New Delhi",
            isRegistered: false
        ),
        Event(
            id: 2,
            imageName: "events",
            title: "AI & Machine Learning Workshop",
            startDate: "Dec 15, 2024 • 9:00 AM",
            endDate: "Dec 17, 2024 • 5:00 PM",
            location: "Tech Hub, Bangalore",
            isRegistered: true
        ),
        Event(
            id: 3,
            imageName: "events",
            title: "Startup Pitch Competition",
            startDate: "Dec 15, 2024 • 9:00 AM",
            endDate: "Dec 17, 2024 • 5:00 PM",
            location: "Business Park, Mumbai",
            isRegistered: false
        ),
        Event(
            id: 4,
            imageName: "events",
            title: "Digital Marketing Masterclass",
            startDate: "Dec 15, 2024 • 9:00 AM",
            endDate: "Dec 17, 2024 • 5:00 PM",
            location: "Marketing Institute, Chennai",
            isRegistered: false
        ),
        Event(
            id: 5,
            imageName: "events",
            title: "Cybersecurity Conference",
            startDate: "Dec 15, 2024 • 9:00 AM",
            endDate: "Dec 17, 2024 • 5:00 PM",
            location: "Security Center, Hyderabad",
            isRegistered: true
        ),
        Event(
            id: 6,
            imageName: "events",
            title: "Blockchain & Web3 Symposium",
            startDate: "Dec 15, 2024 • 9:00 AM",
            endDate: "Dec 17, 2024 • 5:00 PM",
            location: "Innovation Center, Pune",
            isRegistered: false
        ),
        Event(
            id: 7,
            imageName: "events",
            title: "Mobile App Development Hackathon",
            startDate: "Dec 15, 2024 • 9:00 AM",
            endDate: "Dec 17, 2024 • 5:00 PM",
            location: "University Campus, Ahmedabad",
            isRegistered: false
        ),
        Event(
            id: 8,
            imageName: "event8",
            title: "Women in Tech Leadership Forum",
            startDate: "Dec 15, 2024 • 9:00 AM",
            endDate: "Dec 17, 2024 • 5:00 PM",
            location: "Leadership Hall, Kolkata",
            isRegistered: true
        )
    ]
    
    private var filteredEvents: [Event] = []
    private var isSearching: Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupCollectionView()
        containerView.backgroundColor = UIColor(hex: "#007AFF").withAlphaComponent(0.1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filteredEvents = events
    }

    // MARK: - Setup Methods
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
        
        let nib = UINib(nibName: "ParticipantEventCard", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ParticipantEventCard")
        
//        collectionView.backgroundColor = UIColor(hex: "#007AFF").withAlphaComponent(0.1)
//        collectionView.layer.cornerRadius = 16
//        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        collectionView.layer.masksToBounds = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 20
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        }
    }
    
    // MARK: - Helper Methods
    private func getEventsForDisplay() -> [Event] {
        return isSearching ? filteredEvents : events
    }
    
    private func toggleRegistration(for eventId: Int) {
        guard let index = events.firstIndex(where: { $0.id == eventId }) else { return }
        
        let event = events[index]
        let updatedEvent = Event(
            id: event.id,
            imageName: event.imageName,
            title: event.title,
            startDate: event.startDate,
            endDate: event.endDate,
            location: event.location,
            isRegistered: !event.isRegistered
        )
        
        events[index] = updatedEvent
        
        if isSearching, let filteredIndex = filteredEvents.firstIndex(where: { $0.id == eventId }) {
            filteredEvents[filteredIndex] = updatedEvent
        }
        
//        showRegistrationAlert(for: updatedEvent)
    }
    
//    private func showRegistrationAlert(for event: Event) {
//        let message = event.isRegistered ?
//            "Successfully registered for \(event.title)" :
//            "Registration cancelled for \(event.title)"
//        
//        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
//        alert.view.backgroundColor = .white
//        alert.view.alpha = 0.6
//        alert.view.layer.cornerRadius = 15
//        
//        present(alert, animated: true)
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            alert.dismiss(animated: true)
//        }
//    }
    
    private func shareEvent(_ eventId: Int) {
        guard let event = (events.first { $0.id == eventId }) else { return }
        
        let textToShare = "Check out this event: \(event.title) on \(event.startDate) at \(event.location)"
        let activityViewController = UIActivityViewController(
            activityItems: [textToShare],
            applicationActivities: nil
        )
        
        present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionView DataSource
extension ParticipantEventsViewController: UICollectionViewDataSource {
    
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
        
        let event = getEventsForDisplay()[indexPath.item]
        
        // Create cell event
        let cellEvent = ParticipantEventCard.Event(
            id: event.id,
            imageName: event.imageName,
            title: event.title,
            date: event.startDate,
            location: event.location,
            isRegistered: event.isRegistered
        )
        
        // Configure cell
        cell.configure(with: cellEvent)
        
        // Set callbacks
        cell.onRegisterTap = { [weak self] eventId, isCurrentlyRegistered in
            self?.toggleRegistration(for: eventId)
        }
        
        cell.onShareTap = { [weak self] eventId in
            self?.shareEvent(eventId)
        }
        
        cell.backgroundColor = .clear
        
        return cell
    }
}

// MARK: - UICollectionView Delegate FlowLayout
extension ParticipantEventsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 32
        let height: CGFloat = 285
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let event = getEventsForDisplay()[indexPath.item]
        
        // Instantiate the detail view controller
        let detailVC = ParticipantEventDetailViewController()
        
        detailVC.hidesBottomBarWhenPushed = true
        
        // Load the XIB
//        let nibName = "ParticipantEventDetailViewController"
//        let bundle = Bundle(for: ParticipantEventDetailViewController.self)
//        detailVC.loadViewIfNeeded() // This loads the XIB
        
        // Pass the event data
        detailVC.event = event
        
        // Present or push the view controller
        // Option 1: Push (if you have navigation controller)
        navigationController?.pushViewController(detailVC, animated: true)
        
        // Option 2: Present modally
        // detailVC.modalPresentationStyle = .pageSheet
        // present(detailVC, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension ParticipantEventsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredEvents = events
        } else {
            isSearching = true
            filteredEvents = events.filter { event in
                return event.title.lowercased().contains(searchText.lowercased()) ||
                       event.location.lowercased().contains(searchText.lowercased()) ||
                       event.startDate.lowercased().contains(searchText.lowercased())
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
