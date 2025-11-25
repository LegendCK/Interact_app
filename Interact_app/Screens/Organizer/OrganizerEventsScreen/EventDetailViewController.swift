//
//  EventDetailViewController.swift
//  Interact-UIKit
//
//  Created by admin73 on 10/11/25.
//


import UIKit

import CoreData

enum EventStatus {
    case pending
    case upcoming
    case past
}

class EventDetailViewController: UIViewController {

    @IBOutlet weak var eventImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var venueLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var viewRegistrationsButton: ButtonComponent!
    
    @IBOutlet weak var viewRSVPButton: ButtonComponent!
    
    @IBOutlet weak var awaitingVerificationButton: ButtonComponent!
    
    @IBOutlet weak var whatsappGrpButton: ButtonComponent!
    
    @IBOutlet weak var announceWinnersButton: ButtonComponent!
    
    @IBOutlet weak var winnersContainerView: UIView!
    
    @IBOutlet weak var firstPrizeLabel: UILabel!
    @IBOutlet weak var firstPrizeIcon: UIImageView!
    
    @IBOutlet weak var secondPrizeLabel: UILabel!
    @IBOutlet weak var secondPrizeIcon: UIImageView!
    
    @IBOutlet weak var thirdPrizeLabel: UILabel!
    @IBOutlet weak var thirdPrizeIcon: UIImageView!
    
    // MARK: - Properties
    var event: UserEvent!
    
    private let goldColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
    private let silverColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
    private let bronzeColor = UIColor(red: 0.80, green: 0.50, blue: 0.20, alpha: 1.0)
        
        // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshEventData()
        configureButtonVisibility()
        setupWinnersDisplay()
    }

    private func refreshEventData() {
        // Reload the event to get updated winnersAnnounced status
        if let eventId = event.id {
            if let updatedEvent = CoreDataManager.shared.fetchEvent(by: eventId) {
                event = updatedEvent
            }
        }
    }

        
        // MARK: - Setup
        private func setupButtons() {
            // View Registrations Button
            viewRegistrationsButton.configure(
                title: "View Registrations",
                backgroundColor: .systemBlue,
            )
            
            viewRegistrationsButton.onTap = { [weak self] in
                print("View Registrations tapped for: \(self?.event.eventName ?? "Unknown Event")")
                
                guard let self = self else { return }
                
                // ✅ For XIB-based ViewController
                let registrationsVC = RegistrationsListViewController(nibName: "RegistrationsListViewController", bundle: nil)
                registrationsVC.event = self.event
                self.navigationController?.pushViewController(registrationsVC, animated: true)
            }
           
            // View RSVP Button
            viewRSVPButton.configure(
                title: "View RSVP",
                backgroundColor: .systemBlue,
            )
            
            // In your setupButtons() method, update the RSVP button:
            viewRSVPButton.onTap = { [weak self] in
                print("View RSVP tapped for: \(self?.event.eventName ?? "Unknown Event")")
                
                guard let self = self else { return }
                
                // Navigate to RSVP View Controller
                let rsvpVC = RSVPViewController(nibName: "RSVPViewController", bundle: nil)
                rsvpVC.event = self.event
                self.navigationController?.pushViewController(rsvpVC, animated: true)
            }
            
            announceWinnersButton.configure(
                title: "Announce Winners",
                backgroundColor: .systemBlue,
            )
            
            announceWinnersButton.onTap = { [weak self] in
                print("Announce Winners Button Clicked")
                
                guard let self = self else { return }
                
                // Use the custom initializer
                let winnersVC = WinnersSelectionViewController(event: self.event)
                self.navigationController?.pushViewController(winnersVC, animated: true)
            }
            
            awaitingVerificationButton.configure(
                title: "Awaiting Verification",
                backgroundColor: .lightGray,
            )
            
            awaitingVerificationButton.onTap = {
                print("Awaiting Verification Clicked")
            }
            
            // WhatsApp Group Button
            whatsappGrpButton.configure(
                title: "Join WhatsApp Group",
                backgroundColor: .systemGreen,
            )
            
            whatsappGrpButton.onTap = { [weak self] in
                self?.openWhatsAppGroup()
            }
        }
        
        private func setupUI() {
            // Set event image
            if let imageData = event.posterImageData, let image = UIImage(data: imageData) {
                eventImageView.image = image
            } else {
                eventImageView.image = UIImage(named: "events") ?? UIImage(systemName: "photo")
            }
            
            // Set event details
            titleLabel.text = event.eventName ?? "Unnamed Event"
            venueLabel.text = event.location ?? "No location specified"
            descriptionLabel.text = event.eventDescription ?? "No description available"
            
            // Format and set date
            dateLabel.text = formatEventDates()
            
            configureButtonVisibility()
            
            // Style the image view
            eventImageView.layer.cornerRadius = 12
            eventImageView.clipsToBounds = true
            eventImageView.contentMode = .scaleAspectFill
        }
        
        // MARK: - Date Formatting
        private func formatEventDates() -> String {
            guard let startDate = event.startDate,
                  let endDate = event.endDate else {
                return "Date not specified"
            }
            
            let dateFormatter = DateFormatter()
            
            // If same day, show: "Nov 15, 2024 · 9:00 AM - 5:00 PM"
            if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
                dateFormatter.dateFormat = "E, d MMM yyyy"
                let dateString = dateFormatter.string(from: startDate)
                
                dateFormatter.dateFormat = "h:mm a"
                let startTime = dateFormatter.string(from: startDate)
                let endTime = dateFormatter.string(from: endDate)
                
                return "\(dateString) · \(startTime) – \(endTime)"
            } else {
                // Different days: "Nov 15-16, 2024 · 9:00 AM"
                dateFormatter.dateFormat = "MMM d"
                let startDay = dateFormatter.string(from: startDate)
                let endDay = dateFormatter.string(from: endDate)
                
                dateFormatter.dateFormat = "yyyy"
                let year = dateFormatter.string(from: startDate)
                
                dateFormatter.dateFormat = "h:mm a"
                let startTime = dateFormatter.string(from: startDate)
                let endTime = dateFormatter.string(from: endDate)
                
                return "\(startDay),\(year) - \(startTime) · \(endDay),\(year) – \(endTime)"
            }
        }
        
        // MARK: - Event Status Calculation
        private func getEventStatus() -> EventStatus {
            let now = Date()
            
            guard let endDate = event.endDate else {
                return .pending // If dates are missing, treat as pending
            }
            
            // First check if event is approved
            if !event.isApproved {
                return .pending
            }
            
            // Check event timeline for approved events
            if now < endDate {
                return .upcoming
            } else {
                return .past
            }
        }
        
        private func configureButtonVisibility() {
            let status = getEventStatus()
            let now = Date()
            
            let isEventStarted = event.startDate != nil && now > event.startDate!
            let shouldShowAnnounceWinners = isEventStarted && !event.winnersAnnounced
            announceWinnersButton.isHidden = !shouldShowAnnounceWinners
            
            switch status {
            case .pending:
                // Both buttons hidden for pending events
                viewRegistrationsButton.isHidden = true
                viewRSVPButton.isHidden = true
                awaitingVerificationButton.isHidden = false
                announceWinnersButton.isHidden = true
            case .upcoming:
                // Both buttons visible for upcoming events
                viewRegistrationsButton.isHidden = false
                viewRSVPButton.isHidden = false
                awaitingVerificationButton.isHidden = true
            case .past:
                // Both buttons hidden for past events
                viewRegistrationsButton.isHidden = true
                viewRSVPButton.isHidden = true
                awaitingVerificationButton.isHidden = true
            }
            
            // Always show WhatsApp button if link is available
            whatsappGrpButton.isHidden = (event.whatsappGroupLink?.isEmpty ?? true)
            
            // Debug print to verify status
            print("Event Status: \(status)")
            print("Event isApproved: \(event.isApproved)")
            print("Registrations Button Hidden: \(viewRegistrationsButton.isHidden)")
            print("RSVP Button Hidden: \(viewRSVPButton.isHidden)")
            print("WhatsApp Button Hidden: \(whatsappGrpButton.isHidden)")
        }
        
        // MARK: - WhatsApp Group Handling
        private func openWhatsAppGroup() {
            guard let whatsappLinkString = event.whatsappGroupLink,
                  !whatsappLinkString.isEmpty,
                  let url = URL(string: whatsappLinkString) else {
                
                showAlert(title: "No WhatsApp Group", message: "No WhatsApp group link available for this event.")
                return
            }
            
            // Validate URL format
            guard UIApplication.shared.canOpenURL(url) else {
                showAlert(title: "Invalid Link", message: "The WhatsApp group link appears to be invalid.")
                return
            }
            
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    print("Successfully opened WhatsApp group link: \(url.absoluteString)")
                } else {
                    self.showAlert(title: "Cannot Open Link", message: "Unable to open the WhatsApp group link. Please check if WhatsApp is installed.")
                }
            }
        }
    
    private func setupWinnersDisplay() {
        guard let eventId = event.id else { return }
        
        let winners = CoreDataManager.shared.getWinners(for: eventId)
        let hasWinners = !winners.isEmpty && event.winnersAnnounced
        
        winnersContainerView.isHidden = !hasWinners
        
        if hasWinners {
            populateWinners(winners)
        }
    }

    private func populateWinners(_ winners: [Team]) {
        for winner in winners {
            switch winner.prizeRank {
            case 1:
                firstPrizeLabel.text = "\(winner.teamName ?? "") - \(winner.teamLeader ?? "")"
                firstPrizeIcon.tintColor = goldColor
            case 2:
                secondPrizeLabel.text = "\(winner.teamName ?? "") - \(winner.teamLeader ?? "")"
                secondPrizeIcon.tintColor = silverColor
            case 3:
                thirdPrizeLabel.text = "\(winner.teamName ?? "") - \(winner.teamLeader ?? "")"
                thirdPrizeIcon.tintColor = bronzeColor
            default:
                break
            }
        }
    }
        
        // MARK: - Alert Helper
        private func showAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
}
