//
//  ParticipantEventDetailViewController.swift
//  Interact_app
//
//  Created by admin73 on 15/12/25.
//

import UIKit

class ParticipantEventDetailViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet weak var eventImage: UIImageView!
    
    @IBOutlet weak var eventName: UILabel!
    
    @IBOutlet weak var eventDates: UILabel!
    
    @IBOutlet weak var eventTimings: UILabel!
    
    @IBOutlet weak var eventLocation: UILabel!
    
    @IBOutlet weak var registerButton: ButtonComponent!
    
    @IBOutlet weak var infoContainerView: UIView!
    
    @IBOutlet weak var eligibilityCriteriaView: UIView!
    @IBOutlet weak var eligibilityCriteriaLabel: UILabel!
    
    @IBOutlet weak var organizerInfoContainerView: UIView!
    
    @IBOutlet weak var eventDetailsContainerView: UIView!
    
    @IBOutlet weak var eventDetailLabel: UILabel!
    
    @IBOutlet weak var datesContainer: UIView!
    
    @IBOutlet weak var organizerDetailsContainer: UIView!
    
    @IBOutlet weak var orgnaizerDetailContainer: UIView!
    
    @IBOutlet weak var viewRegistrationsButton: ButtonComponent!
    
    @IBOutlet weak var viewRSVPbutton: ButtonComponent!
    
    @IBOutlet weak var announceWinnersButton: ButtonComponent!
    
    
    
    // MARK: - Properties
        // This property will receive data from the previous screen
    var event: Event?
    
    enum DetailMode {
        case participant
        case organizer
    }

    var mode: DetailMode = .participant

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInfo()
        setupUI()
        
        // Debug: Check if button exists
            print("Button component exists: \(registerButton != nil)")
            print("Button inside component exists: \(registerButton.button != nil)")
            print("Button frame: \(registerButton.frame)")
    }
    
    
    private func setupInfo() {
            guard let event = event else { return }
            
            // 1. Set Texts
            eventName.text = event.title
            eventLocation.text = event.location ?? "Online Event"
            
            // 2. Format Dates
            // Assuming you want a format like "Mon, 12 Dec - 10:00 AM"
//            eventStartDate.text = event.startDate.toEventString()
            eventDates.text = Date.eventDateRangeString(start: event.startDate, end: event.endDate)
//            eventEndDate.text = event.endDate.toEventString()
            eventTimings.text = Date.eventTimeRangeString(start: event.startDate, end: event.endDate)
            
            eventDetailLabel.text = event.description
        
        if let criteria = event.eligibilityCriteria, !criteria.isEmpty {
            eligibilityCriteriaLabel.text = criteria
        } else {
            eligibilityCriteriaView.isHidden = true
        }

        
            // 3. Load Image (Async)
        let urlString = event.thumbnailUrl

        if !urlString.isEmpty, let url = URL(string: urlString) {
            loadImage(from: url)
        } else {
            eventImage.image = UIImage(systemName: "photo")
            eventImage.tintColor = .systemGray4
        }

//        
//        if Date() > event.registrationDeadline {
//            registerButton.configure(
//                title: "Registration Closed",
//                titleColor: .white,
//                backgroundColor: .systemGray
//            )
//            registerButton.isUserInteractionEnabled = false
//        }

        }
    
    private func setupUI() {
        infoContainerView.layer.cornerRadius = 10
        organizerInfoContainerView.layer.cornerRadius = 10
        eventDetailsContainerView.layer.cornerRadius = 10
        eligibilityCriteriaView.layer.cornerRadius = 10
        eventImage.layer.cornerRadius = 10
        datesContainer.layer.cornerRadius = 10
        organizerDetailsContainer.layer.cornerRadius = 10
        orgnaizerDetailContainer.layer.cornerRadius = 10
//        containerView.backgroundColor = UIColor(hex: "#007AFF").withAlphaComponent(0.1)
        containerView.backgroundColor = .systemGroupedBackground
        
        
        // Configure Containers
                let containers = [infoContainerView, organizerInfoContainerView, eventDetailsContainerView, eligibilityCriteriaView,datesContainer,organizerDetailsContainer,orgnaizerDetailContainer]
                containers.forEach { view in
                    view?.layer.cornerRadius = 12
                    view?.backgroundColor = .white
                    view?.layer.shadowColor = UIColor.black.cgColor
                    view?.layer.backgroundColor = UIColor.secondarySystemGroupedBackground.cgColor
                    view?.layer.shadowOffset = CGSize(width: 0, height: 2)
                    view?.layer.shadowRadius = 6
                    view?.layer.shadowOpacity = 0.05
                    view?.layer.masksToBounds = false
                }
        registerButton.configure(
            title: "Register",
            titleColor: .white,
            backgroundColor: .systemBlue,
            cornerRadius: 8,
            font: .systemFont(ofSize: 16, weight: .semibold),
        )
        
        registerButton.button.removeTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
            // Then add the target
        registerButton.button.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        
        // Add target for button
            registerButton.onTap = { [weak self] in
                self?.didTapRegister()
            }
        
        switch mode {
        case .participant:
            // Participant sees Register
            registerButton.isHidden = false

            viewRegistrationsButton.isHidden = true
            viewRSVPbutton.isHidden = true
            announceWinnersButton.isHidden = true

        case .organizer:
            // Organizer does NOT see Register
            registerButton.isHidden = true

            viewRegistrationsButton.isHidden = false
            viewRSVPbutton.isHidden = false
            announceWinnersButton.isHidden = false

            setupOrganizerButtons()
        }

    }
    
    private func setupOrganizerButtons() {
        viewRegistrationsButton.configure(
            title: "View Registrations",
            titleColor: .white,
            backgroundColor: .systemBlue,
            cornerRadius: 8
        )

        viewRSVPbutton.configure(
            title: "View RSVP",
            titleColor: .white,
            backgroundColor: .systemBlue,
            cornerRadius: 8
        )

        announceWinnersButton.configure(
            title: "Announce Winners",
            titleColor: .white,
            backgroundColor: .systemBlue,
            cornerRadius: 8
        )
        
        viewRegistrationsButton.onTap = { [weak self] in
            self?.navigateToViewRegistrations()
        }

        viewRSVPbutton.onTap = { [weak self] in
            self?.navigateToRSVP()
        }

        announceWinnersButton.onTap = { [weak self] in
            self?.navigateToWinnerSelection()
        }

    }
    
    private func navigateToViewRegistrations() {
        guard let eventId = event?.id else { return }

        let vc = RegistrationsListViewController(eventId: eventId)
        vc.title = "Approve Event"
        navigationController?.pushViewController(vc, animated: true)
    }


    private func navigateToRSVP() {
        guard let eventId = event?.id else { return }

        let vc = RSVPViewController(eventId: eventId)
        vc.title = "Edit Event"
        navigationController?.pushViewController(vc, animated: true)
    }

    private func navigateToWinnerSelection() {
        guard let eventId = event?.id else { return }

        let vc = WinnersSelectionViewController(eventId: eventId)
        vc.title = "Announce Winners"
        navigationController?.pushViewController(vc, animated: true)
    }



    // MARK: - Actions
        @objc private func didTapRegister() {
            
            print("✅ Register button tapped! Event ID: \(event?.id)")
            guard let eventId = self.event?.id else { return }
            
            // 1. UI Feedback: Prevent double taps
            registerButton.isUserInteractionEnabled = false
            registerButton.alpha = 0.7
            
            Task {
                do {
                    // 2. Data Fetch: Check User Status (Role & Team)
                    let status = try await TeamService.shared.getUserTeamStatus(eventID: eventId)
                    
                    DispatchQueue.main.async {
                        // Reset UI
                        self.registerButton.isUserInteractionEnabled = true
                        self.registerButton.alpha = 1.0
                        
                        // 3. Routing Logic
                        self.handleNavigation(status: status, eventId: eventId)
                    }
                } catch {
                    print("Error checking team status: \(error)")
                    
                    // Fallback on error (Optional: Show alert instead)
                    DispatchQueue.main.async {
                        self.registerButton.isUserInteractionEnabled = true
                        self.registerButton.alpha = 1.0
                        self.navigateToRegisterTeam(eventId: eventId) // Default to Create flow
                    }
                }
            }
        }
    
    // MARK: - Routing Logic
        private func handleNavigation(status: UserTeamStatus?, eventId: UUID) {
            
            // SCENARIO 1: New User (Status is nil)
            guard let status = status else {
                print("➡️ User has no team. Opening Register Modal.")
                navigateToRegisterTeam(eventId: eventId)
                return
            }
            
            // SCENARIO 2: Team Leader
            if status.my_role == "leader" {
                print("➡️ User is LEADER. Opening Manage Modal.")
                navigateToManageTeam(teamId: status.team_id)
            }
            
            // SCENARIO 3: Team Member
            else {
                print("➡️ User is MEMBER. Opening Read-Only Info Modal.")
                navigateToTeamInfo(teamId: status.team_id, teamName: status.team_name)
            }
        }
        
        // MARK: - Navigation Helpers

        // Scenario 1: Open 'RegisterTeamModal' (Enter Name)
        private func navigateToRegisterTeam(eventId: UUID) {
            let registerTeamVC = RegisterTeamModal()
            registerTeamVC.eventID = eventId

            let navController = UINavigationController(rootViewController: registerTeamVC)
            configureSheet(navController)
            present(navController, animated: true)
        }

        // Scenario 2: Open 'CreateTeamModal' (Manage Members & Invites)
        private func navigateToManageTeam(teamId: UUID) {
            let manageVC = CreateTeamModal()
            manageVC.teamID = teamId // This VC needs to handle fetching members based on ID
            // Note: Ensure CreateTeamModal has an eventID property if it needs it for other logic
            
            let navController = UINavigationController(rootViewController: manageVC)
            configureSheet(navController)
            present(navController, animated: true)
        }
        
        // Scenario 3: Open 'TeamInfoViewController' (Read Only)
        private func navigateToTeamInfo(teamId: UUID, teamName: String) {
            let infoVC = TeamInfoModal() // The Read-Only VC we created earlier
            infoVC.teamID = teamId
            infoVC.teamName = teamName
            
            let navController = UINavigationController(rootViewController: infoVC)
            configureSheet(navController)
            present(navController, animated: true)
        }

        // Helper to style the sheet consistently
        private func configureSheet(_ navController: UINavigationController) {
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
        }

        
        // MARK: - Helper: Image Loader
        private func loadImage(from url: URL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self, let data = data, error == nil, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self.eventImage.image = image
                }
            }.resume()
        }
}
