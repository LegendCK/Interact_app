//
//  EventsScreenViewController.swift
//  Interact-UIKit
//
//  Created by admin73 on 07/11/25.
//

import UIKit
import Foundation
import CoreData

class EventsScreenViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {


    @IBOutlet weak var searchBar: UISearchBar!
   
    @IBOutlet weak var segmentedControl: UISegmentedControl!
       
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var fallbackView: FallBackView!
    
    
    // MARK: - Properties
        private var allEvents: [UserEvent] = []
        private var filteredEvents: [UserEvent] = []
        private var currentSegmentIndex: Int = 0
        
        // MARK: - Event Status
        enum EventStatus {
            case pending
            case upcoming
            case past
        }

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupGradientBackground()
            setupCollectionView()
            setupSegmentedControl()
            searchBar.delegate = self
            addApproveAllButton() 
            loadEventsFromCoreData()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            loadEventsFromCoreData() // Refresh when view appears
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            view.layer.sublayers?.first?.frame = view.bounds
        }

        // MARK: - Core Data
        private func loadEventsFromCoreData() {
            allEvents = CoreDataManager.shared.fetchAllEvents()
            printAllEvents()
            applyFilters()
        }

        // MARK: - Event Status Calculation
//        private func getEventStatus(for event: UserEvent) -> EventStatus {
//            let now = Date()
//            
//            guard let endDate = event.endDate else {
//                return .pending // If dates are missing, treat as pending
//            }
//            
//            // First check if event is approved
//            if !event.isApproved {
//                return .pending
//            }
//
//            // Check event timeline for approved events
//            if now < endDate {
//                return .upcoming
//            } else {
//                return .past
//            }
//        }
//        
//        private func getEventStatusString(for event: UserEvent) -> String {
//            switch getEventStatus(for: event) {
//            case .pending:
//                return "Pending Verification"
//            case .upcoming:
//                return "Upcoming"
//            case .past:
//                return "Past"
//            }
//        }
//        
//        private func getStatusColor(for event: UserEvent) -> UIColor {
//            switch getEventStatus(for: event) {
//            case .pending:
//                return .black
//            case .upcoming:
//                return .systemYellow
//            case .past:
//                return .systemGray
//            }
//        }

        // MARK: - UI Setup
        private func setupGradientBackground() {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [
                UIColor.systemBlue.withAlphaComponent(0.2).cgColor,
                UIColor.white.cgColor
            ]
            gradientLayer.locations = [0.0, 0.25]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            gradientLayer.frame = view.bounds
            view.layer.insertSublayer(gradientLayer, at: 0)
        }

        private func setupCollectionView() {
            let nib = UINib(nibName: "EventCardCell", bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: "EventCardCell")
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.backgroundColor = .clear
        }

        private func setupSegmentedControl() {
            segmentedControl.removeAllSegments()
            let segments = ["All", "Upcoming", "Pending", "Past"]
            for (index, title) in segments.enumerated() {
                segmentedControl.insertSegment(withTitle: title, at: index, animated: false)
            }
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        }

        // MARK: - Admin Approval System
        private func addApproveAllButton() {
            let approveButton = UIButton(type: .system)
            approveButton.setTitle("Approve All", for: .normal)
            approveButton.backgroundColor = .systemGreen
            approveButton.setTitleColor(.white, for: .normal)
            approveButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            approveButton.layer.cornerRadius = 6
            approveButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            approveButton.addTarget(self, action: #selector(approveAllPending), for: .touchUpInside)
            
            // Add as right bar button item
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: approveButton)
        }
        
        @objc private func approveAllPending() {
            let pendingEvents = allEvents.filter { !$0.isApproved }
            
            if pendingEvents.isEmpty {
                showAlert(title: "No Pending Events", message: "All events are already approved!")
                return
            }
            
            for event in pendingEvents {
                event.isApproved = true
                print(" Approved: \(event.eventName ?? "Unnamed")")
            }
            
            CoreDataManager.shared.saveContext()
            loadEventsFromCoreData() // Refresh the view
            
            showAlert(title: "Success", message: "Approved \(pendingEvents.count) pending events")
        }
        
        private func printAllEvents() {
            let AllEvents = allEvents
            
            print("ALL EVENTS (\(AllEvents.count)):")
            
            for (index, event) in AllEvents.enumerated() {
                print("""
                Event #\(index + 1)
                ID: \(event.id?.uuidString ?? "N/A")
                Name: \(event.eventName ?? "Unnamed")
                Location: \(event.location ?? "No location")
                Team Size: \(event.teamSize)
                Reg Count: \(event.registeredCount)
                Start: \(event.startDate?.description ?? "No date")
                isApproved: \(event.isApproved)
                """)
            }
        }
        
        private func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }

        // MARK: - Filter Logic
        @objc func segmentChanged(_ sender: UISegmentedControl) {
            currentSegmentIndex = sender.selectedSegmentIndex
            applyFilters()
        }

        func applyFilters(searchText: String = "") {
            var filtered = allEvents
            
            switch currentSegmentIndex {
            case 1: // Upcoming - Only approved events that haven't ended
                filtered = filtered.filter {
                    $0.isApproved &&
                    ($0.endDate ?? Date()) > Date()
                }
            case 2: // Pending - Not approved yet
                filtered = filtered.filter { !$0.isApproved }
            case 3: // Past - Approved events that have ended
                filtered = filtered.filter {
                    $0.isApproved &&
                    ($0.endDate ?? Date()) <= Date()
                }
            default: // All - Show everything
                break
            }
            
            // Apply search filter
            if !searchText.isEmpty {
                filtered = filtered.filter {
                    ($0.eventName?.lowercased().contains(searchText.lowercased()) ?? false) ||
                    ($0.location?.lowercased().contains(searchText.lowercased()) ?? false) ||
                    ($0.eventDescription?.lowercased().contains(searchText.lowercased()) ?? false)
                }
            }
            
            filteredEvents = filtered
            collectionView.reloadData()
            
            // Show/hide fallback based on empty state
            fallbackView.isHidden = !filteredEvents.isEmpty
            collectionView.isHidden = filteredEvents.isEmpty

            // Update fallback message for each segment
            if filteredEvents.isEmpty {
                updateFallbackMessage()
            }
            
            // Debug print
            print("Filtered events: \(filteredEvents.count)")
//            filteredEvents.forEach { event in
//                print("   - \(event.eventName ?? "Unnamed"): \(getEventStatusString(for: event))")
//            }
        }
    
    private func updateFallbackMessage() {
        switch currentSegmentIndex {
        case 1: // Upcoming
            fallbackView.configure(message: "No upcoming events", showButton: true)
            fallbackView.onCreateEventTapped = { [weak self] in
                self?.showCreateEventModal()
            }
        case 2: // Pending
            fallbackView.configure(message: "No pending events awaiting approval")
        case 3: // Past
            fallbackView.configure(message: "No past events")
        default: // All
            fallbackView.configure(message: "No events found")
        }
    }
    
    private func showCreateEventModal() {
        let createEventVC = CreateEventViewController(nibName: "CreateEventViewController", bundle: nil)
        createEventVC.modalPresentationStyle = .pageSheet
        
        if let sheet = createEventVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(createEventVC, animated: true)
    }

        // MARK: - Collection View Data Source
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return filteredEvents.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCardCell", for: indexPath) as? EventCardCell else {
                return UICollectionViewCell()
            }
            
            let event = filteredEvents[indexPath.item]
            configureCell(cell, with: event)
            return cell
        }
        
        private func configureCell(_ cell: EventCardCell, with event: UserEvent) {
            // Set basic info
            cell.titleLabel.text = event.eventName ?? "Unnamed Event"
            cell.venueLabel.text = event.location ?? "No location"
            
            // Set date information
            if let startDate = event.startDate, let endDate = event.endDate {
                let dateString = formatEventDates(startDate: startDate, endDate: endDate)
                cell.dateLabel.text = dateString
            } else {
                cell.dateLabel.text = "Date not set"
            }
            
            // Set image
            if let imageData = event.posterImageData, let image = UIImage(data: imageData) {
                cell.eventImageView.image = image
            } else {
                cell.eventImageView.image = UIImage(named: "events") ?? UIImage(systemName: "photo")
            }
            
            // Set status badge
//            let status = getEventStatusString(for: event)
//            let statusColor = getStatusColor(for: event)
//            cell.configureStatusBadge(text: status, color: statusColor)
            
            // Configure share button
            cell.shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
            
            // Set up share action
            // cell.shareButtonAction = { [weak self] in
            //     self?.shareEvent(event)
            // }
        }
        
        private func formatEventDates(startDate: Date, endDate: Date) -> String {
            let dateFormatter = DateFormatter()
            
            // If same day, show: "Nov 15, 2024 · 9:00 AM - 5:00 PM"
            if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
                dateFormatter.dateFormat = "E, d MMM yyyy"
                let dateString = dateFormatter.string(from: startDate)
                
                dateFormatter.dateFormat = "h:mm a"
                let startTime = dateFormatter.string(from: startDate)
                let endTime = dateFormatter.string(from: endDate)
                
                return "\(dateString) · \(startTime) - \(endTime)"
            } else {
                // Different days: "Nov 15-16, 2024"
                dateFormatter.dateFormat = "MMM d"
                let startDay = dateFormatter.string(from: startDate)
                let endDay = dateFormatter.string(from: endDate)
                
                dateFormatter.dateFormat = "yyyy"
                let year = dateFormatter.string(from: startDate)
                
                return "\(startDay) - \(endDay), \(year)"
            }
        }
        
        private func shareEvent(_ event: UserEvent) {
            let eventName = event.eventName ?? "Unnamed Event"
            let location = event.location ?? "No location"
            let description = event.eventDescription ?? "No description"
            
            let shareText = """
            Check out this event: \(eventName)
            
            Location: \(location)
            Description: \(description)
            
            Shared via Interact App
            """
            
            let activityViewController = UIActivityViewController(
                activityItems: [shareText],
                applicationActivities: nil
            )
            
            // For iPad
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            present(activityViewController, animated: true)
        }

        // MARK: - Collection View Layout
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            let horizontalInset: CGFloat = 16
            let availableWidth = collectionView.frame.width - (horizontalInset * 2)
            let aspectRatio: CGFloat = 200 / 320
            var height = availableWidth * aspectRatio
            let maxHeight: CGFloat = 230
            let minHeight: CGFloat = 180
            height = min(maxHeight, max(minHeight, height))
            return CGSize(width: availableWidth, height: height)
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            insetForSectionAt section: Int) -> UIEdgeInsets {
            UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            10
        }

        // MARK: - Search
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            applyFilters(searchText: searchText)
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }

        // MARK: - Navigation
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let selectedEvent = filteredEvents[indexPath.item]
            showEventDetails(event: selectedEvent)
        }
        
        private func showEventDetails(event: UserEvent) {
            let detailVC = EventDetailViewController()
            detailVC.event = event
            detailVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(detailVC, animated: true)
        }

}
