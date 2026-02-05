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
    private var featuredEvents: [Event] = [] // Changed to Event model from Supabase
    private var backgroundGradientLayer: CAGradientLayer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyBackgroundGradient()
        setupButtons()
        setupFeaturedEventsCollectionView()
        setupOngoingEventsCollectionView()
        setupSeeAllButton()
        
        // Initialize Supabase client if needed
        initializeSupabaseIfNeeded()
        
        // Fetch featured events from Supabase
        fetchFeaturedEvents()
        
        // Load ongoing events from CoreData
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

    // MARK: - Supabase Initialization
    private func initializeSupabaseIfNeeded() {
        if EventService.shared.client == nil {
            print("⚠️ Initializing Supabase Client in Organizer Home.")
            
            do {
                let config = try SupabaseConfig()
                EventService.shared.client = SupabaseClient(config: config)
                print("✅ Supabase Client initialized successfully.")
            } catch {
                print("❌ Failed to load Supabase Config: \(error)")
            }
        }
    }
    
    // MARK: - Fetch Featured Events
    private func fetchFeaturedEvents() {
        Task {
            do {
                // Fetch events from Supabase
                let fetchedEvents = try await EventService.shared.fetchUpcomingEvents()
                
                // Take only first 3-4 events for featured section
                self.featuredEvents = Array(fetchedEvents.prefix(4))
                
                DispatchQueue.main.async {
                    self.featuredEventsCollectionView.reloadData()
                    self.updatePageControls()
                }
            } catch {
                print("Error fetching featured events: \(error)")
                // Optionally show error to user
            }
        }
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
    }

    // MARK: - Page Control Updates
    private func updatePageControls() {
        featuredPageControl.numberOfPages = featuredEvents.count
        ongoingPageControl.numberOfPages = ongoingEvents.count
        ongoingPageControl.isHidden = ongoingEvents.isEmpty
    }
    
    private func updateFeaturedPageControl() {
        let width = featuredEventsCollectionView.frame.width
        let page = Int((featuredEventsCollectionView.contentOffset.x + width / 2) / width)
        featuredPageControl.currentPage = max(0, min(page, featuredEvents.count - 1))
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
            return ongoingEvents.isEmpty ? 0 : ongoingEvents.count
        }
        return featuredEvents.count
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
            // Featured Events - Using real data from Supabase
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCardCell", for: indexPath) as! EventCardCell
            let event = featuredEvents[indexPath.item]
            
            // Configure with real event data
            cell.titleLabel.text = event.title
            cell.dateLabel.text = event.startDate.toEventString()
            cell.venueLabel.text = event.locationType == .online ? "Online Event" : (event.location ?? "TBA")
            cell.shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
            
            // Load event image
            if !event.thumbnailUrl.isEmpty, let imageUrl = URL(string: event.thumbnailUrl) {
                loadEventImage(into: cell.eventImageView, from: imageUrl)
            } else {
                cell.eventImageView.image = UIImage(named: "event_placeholder")
            }
            
            return cell
        }
    }
    
    // MARK: - Helper Methods
    private func loadEventImage(into imageView: UIImageView, from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    imageView.image = UIImage(named: "event_placeholder")
                }
                return
            }
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
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
            return UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    // MARK: - Navigation
    private func showEventDetails(event: UserEvent) {
        let detailVC = EventDetailViewController()
        detailVC.event = event
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Only handle tap for featured events collection view
        if collectionView == featuredEventsCollectionView {
            // Navigate to Participant Event Detail (since organizers can view participant events too)
            let selectedEvent = featuredEvents[indexPath.item]
            let detailVC = ParticipantEventDetailViewController(nibName: "ParticipantEventDetailViewController", bundle: nil)
            detailVC.event = selectedEvent
            detailVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(detailVC, animated: true)
        }
        // OngoingEventCollectionView tap is already handled by cell's onViewEventTapped closure
    }
}
