//
//  HomeScreenViewController.swift
//  Interact-UIKit
//
//  Created by admin73 on 08/11/25.
//

import UIKit

class HomeScreenViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var scanQRBtton: ButtonComponent!
    @IBOutlet weak var createEventButton: ButtonComponent!

    @IBOutlet weak var featuredEventsCollectionView: UICollectionView!
    @IBOutlet weak var featuredPageControl: UIPageControl!
    
    @IBOutlet weak var OngoingEventCollectionView: UICollectionView!
    @IBOutlet weak var ongoingPageControl: UIPageControl!
    
    @IBOutlet weak var verificationCard: VerificationCard!
    
    @IBOutlet weak var seeAllButton: UIButton!
    
    
    
    // MARK: - Properties
    private var ongoingEvents: [UserEvent] = []
    private var backgroundGradientLayer: CAGradientLayer?
    
    enum EventStatus {
        case active
        case ended
    }

    struct Event {
        let image: UIImage?
        let title: String
        let datetime: String
        let venue: String
        let status: EventStatus
    }
    
    let events: [Event] = [
        Event(
            image: UIImage(named: "events2"),
            title: "Ossome Hacks 2.0",
            datetime: "Fri, 31 Oct 2025 · 9:00 am – 6:00 pm",
            venue: "SRMIST KTR, Chennai",
            status: .active
        ),
        Event(
            image: UIImage(named: "events2"),
            title: "AI Innovation Summit 2025",
            datetime: "Mon, 21 Jul 2025 · 10:00 am – 5:00 pm",
            venue: "Chennai Trade Center",
            status: .ended
        ),
        Event(
            image: UIImage(named: "events2"),
            title: "HackFest 2026",
            datetime: "Fri, 15 Jan 2026 · 9:00 am – 9:00 pm",
            venue: "Bangalore Tech Park",
            status: .active
        )
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyBackgroundGradient()
        setupButtons()
        setupFeaturedEventsCollectionView()
        setupOngoingEventsCollectionView()
        setupSeeAllButton()
        
        // Call this once when app launches
//        CoreDataManager.shared.populateDummyParticipantsForAllEvents()
//        CoreDataManager.shared.populateDummyTeamsForAllEvents()
//        let eventId = UUID(uuidString: "603200C2-B61A-4690-B4B0-885054E19762")!
//        CoreDataManager.shared.deleteEventAndParticipants(by: eventId)
        
        loadOngoingEvents()
        updatePageControls()
        
        // PAGE CONTROL COLORS
        featuredPageControl.pageIndicatorTintColor = UIColor.systemGray3
        featuredPageControl.currentPageIndicatorTintColor = UIColor.systemBlue

        ongoingPageControl.pageIndicatorTintColor = UIColor.systemGray3
        ongoingPageControl.currentPageIndicatorTintColor = UIColor.systemBlue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadOngoingEvents()
        updatePageControls()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer?.frame = view.bounds
    }

    // MARK: - Background
    private func applyBackgroundGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.systemBlue.withAlphaComponent(0.2).cgColor,
            UIColor.white.cgColor
        ]
        gradient.locations = [0.0, 0.25]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        backgroundGradientLayer = gradient
    }

    // MARK: - Buttons
    private func setupButtons() {
        scanQRBtton.configure(
            title: "Scan Check-In",
            titleColor: .white,
            backgroundColor: .systemBlue,
            image: UIImage(systemName: "qrcode"),
            imagePlacement: .leading
        )
        
        scanQRBtton.onTap = {
            print("Scan QR Button tapped")
        }
        
        createEventButton.configure(
            title: "Create Event",
            titleColor: .white,
            backgroundColor: .systemBlue,
            image: UIImage(systemName: "plus"),
            imagePlacement: .leading
        )
        
        createEventButton.onTap = { [weak self] in
            guard let self = self else { return }
            
            let createEventVC = CreateEventViewController(nibName: "CreateEventViewController", bundle: nil)
            createEventVC.modalPresentationStyle = .pageSheet
            
            if let sheet = createEventVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
            
            self.present(createEventVC, animated: true)
        }
    }
    
    private func setupSeeAllButton() {
            // Add target action to the button
            seeAllButton.addTarget(self, action: #selector(seeAllButtonTapped), for: .touchUpInside)
        }
    
    @objc private func seeAllButtonTapped() {
            // Simply switch to Events tab (index 1)
            tabBarController?.selectedIndex = 1
        }
        
    
    // MARK: - Featured Events Collection View
    private func setupFeaturedEventsCollectionView() {
        let nib = UINib(nibName: "EventCardCell", bundle: nil)
        featuredEventsCollectionView.register(nib, forCellWithReuseIdentifier: "EventCardCell")
        
        featuredEventsCollectionView.dataSource = self
        featuredEventsCollectionView.delegate = self
        featuredEventsCollectionView.backgroundColor = .clear
        featuredEventsCollectionView.isPagingEnabled = true
        
        if let layout = featuredEventsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16)
        }
    }

    // MARK: - Ongoing Events Collection View
    private func setupOngoingEventsCollectionView() {
        OngoingEventCollectionView.dataSource = self
        OngoingEventCollectionView.delegate = self
        OngoingEventCollectionView.isPagingEnabled = true
        
        let nib = UINib(nibName: "OngoingEventCard", bundle: nil)
        OngoingEventCollectionView.register(nib, forCellWithReuseIdentifier: "OngoingEventCard")
        
        if let layout = OngoingEventCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
        
        OngoingEventCollectionView.backgroundColor = .clear
    }

    // MARK: - Load Events
    private func loadOngoingEvents() {
        let allEvents = CoreDataManager.shared.fetchAllEvents()
        
        ongoingEvents = allEvents.filter { event in
            guard event.isApproved,
                  let regDeadline = event.registrationDeadline,
                  let endDate = event.endDate else { return false }
            
            let now = Date()
            return now >= regDeadline && now <= endDate
        }
        
        OngoingEventCollectionView.reloadData()
        updatePageControls()
        
        // Show/hide based on empty state
        verificationCard.isHidden = !ongoingEvents.isEmpty
        OngoingEventCollectionView.isHidden = ongoingEvents.isEmpty
        
//        OngoingEventCollectionView.backgroundView = ongoingEvents.isEmpty ? createEmptyStateView() : nil
    }
    
//    private func createEmptyStateView() -> UIView {
//        let fallbackCard = VerificationCard()
//        fallbackCard.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Create a container view
//        let containerView = UIView()
//        containerView.addSubview(fallbackCard)
//        
//        // Set constraints between fallbackCard and containerView
//        NSLayoutConstraint.activate([
//            fallbackCard.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//            fallbackCard.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//            fallbackCard.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
//            fallbackCard.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
//            fallbackCard.heightAnchor.constraint(equalToConstant: 220)
//        ])
//        
//        return containerView
//    }

    // MARK: - Page Control Updates
    private func updatePageControls() {
        featuredPageControl.numberOfPages = events.count
        ongoingPageControl.numberOfPages = ongoingEvents.count
        ongoingPageControl.isHidden = ongoingEvents.isEmpty
    }
    
    private func updateFeaturedPageControl() {
        let width = featuredEventsCollectionView.frame.width
        let page = Int((featuredEventsCollectionView.contentOffset.x + width / 2) / width)
        featuredPageControl.currentPage = max(0, min(page, events.count - 1))
    }
    
    private func updateOngoingPageControl() {
        let width = OngoingEventCollectionView.frame.width
        let page = Int((OngoingEventCollectionView.contentOffset.x + width / 2) / width)
        ongoingPageControl.currentPage = max(0, min(page, ongoingEvents.count - 1))
    }

    // MARK: - Scroll View Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == featuredEventsCollectionView {
            updateFeaturedPageControl()
        } else if scrollView == OngoingEventCollectionView {
            updateOngoingPageControl()
        }
    }
    
    // MARK: - Collection View DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == OngoingEventCollectionView {
            return ongoingEvents.isEmpty ? 0 : ongoingEvents.count // Return 0 when empty to prevent cells
        }
        return events.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == OngoingEventCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OngoingEventCard", for: indexPath) as! OngoingEventCard
            let event = ongoingEvents[indexPath.item]
            cell.configure(with: event)
            cell.onViewEventTapped = { [weak self] in
                self?.showEventDetails(event: event)
            }
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCardCell", for: indexPath) as! EventCardCell
            let event = events[indexPath.item]
            cell.eventImageView.image = event.image
            cell.titleLabel.text = event.title
            cell.dateLabel.text = event.datetime
            cell.venueLabel.text = event.venue
            cell.shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
            return cell
        }
    }

    // MARK: - Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == OngoingEventCollectionView {
            let horizontalInset: CGFloat = 16
            let availableWidth = collectionView.frame.width - (horizontalInset * 2)
            let aspectRatio: CGFloat = 218 / 336
            var height = availableWidth * aspectRatio
            let maxHeight: CGFloat = 218
            let minHeight: CGFloat = 180
            height = min(maxHeight, max(minHeight, height))
            return CGSize(width: availableWidth, height: height)
        } else {
            let horizontalInset: CGFloat = 16
            let availableWidth = collectionView.frame.width - (horizontalInset * 2)
            let aspectRatio: CGFloat = 200 / 320
            var height = availableWidth * aspectRatio
            let maxHeight: CGFloat = 230
            let minHeight: CGFloat = 180
            height = min(maxHeight, max(minHeight, height))
            return CGSize(width: availableWidth, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == OngoingEventCollectionView {
            return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        } else {
            return UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16) }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == OngoingEventCollectionView {
            return 16
        } else {
            return 16 }
    }

    // MARK: - Navigation
    private func showEventDetails(event: UserEvent) {
        let detailVC = EventDetailViewController()
        detailVC.event = event
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

