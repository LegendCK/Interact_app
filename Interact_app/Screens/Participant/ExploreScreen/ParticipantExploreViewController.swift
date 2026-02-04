//
//  ParticipantExploreViewController.swift
//  Interact_app
//
//  Created by admin56 on 17/11/25.
//

import UIKit

class ParticipantExploreViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - ViewModel
    var viewModel: ParticipantProfileViewModel!
    
    // MARK: - Data Arrays (temporary mock data)
    private let roles = ["UI/UX", "Web Dev", "App Dev", "AI/ML", "Cyber"]
    private let roleIcons = ["paintbrush.fill", "laptopcomputer", "iphone", "cpu", "lock.shield.fill"]
    
    private var partnerBanners: [String] = ["partner_banner"] // placeholder image names
    
    private var teams: [(name: String, members: Int, event: String)] = [
        ("Code Warriors", 5, "HackNITR 5.0"),
        ("Tech Ninjas", 3, "Smart India Hackathon"),
        ("Dev Squad", 4, "ETHIndia 2025")
    ]
    
    private var events: [(title: String, date: String, venue: String, image: String)] = [
        ("HackNITR 5.0", "Feb 15-16, 2025", "NIT Rourkela", "Hackpril26"),
        ("Smart India", "March 5, 2025", "Online", "Hackpril26"),
        ("ETHIndia", "April 20-22, 2025", "Bengaluru", "Hackpril26")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadProfile()
    }
    
    // MARK: - Load Profile
    private func loadProfile() {
        viewModel.loadProfileIfNeeded()
        
        viewModel.onProfileLoaded = { [weak self] in
            self?.collectionView.reloadData()
        }
        
        viewModel.onError = { [weak self] errorMessage in
            print("Profile error: \(errorMessage)")
        }
    }
    
    // MARK: - Setup Collection View
    private func setupCollectionView() {
        // Register main header (for section 0)
        collectionView.register(
            UINib(nibName: "HomeHeaderViewCollectionReusableView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HomeHeaderViewCollectionReusableView"
        )
        
        // Register section headers (for sections 1, 3, 4)
        collectionView.register(
            UINib(nibName: "SectionHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeaderView"
        )
        
        // Register cells
        collectionView.register(
            UINib(nibName: "RoleCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "RoleCollectionViewCell"
        )
        
        collectionView.register(
            UINib(nibName: "BannerCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "BannerCollectionViewCell"
        )
        
        collectionView.register(
            UINib(nibName: "TeamCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "TeamCollectionViewCell"
        )
        
        collectionView.register(
            UINib(nibName: "EventCardCell", bundle: nil),
            forCellWithReuseIdentifier: "EventCardCell"
        )
        
        // Set compositional layout
        collectionView.collectionViewLayout = createCompositionalLayout()
        
        // Set delegate and dataSource
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // MARK: - Compositional Layout
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            
            switch sectionIndex {
            case 0:
                return self.createMainHeaderSection()
            case 1:
                return self.createRolesSection()
            case 2:
                return self.createBannerSection()
            case 3:
                return self.createTeamsSection()
            case 4:
                return self.createEventsSection()
            default:
                return nil
            }
        }
    }
    
    // MARK: - Section 0: Main Header Only (no cells)
    private func createMainHeaderSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(1)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        // Add main header (greeting + search)
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    // MARK: - Section 1: Roles (Horizontal scrolling)
    private func createRolesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(80),
            heightDimension: .absolute(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(80),
            heightDimension: .absolute(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16)
        
        // Add "Browse by Roles" header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    // MARK: - Section 2: Partner Banner (no header)
    private func createBannerSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(180)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.9),
            heightDimension: .absolute(180)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16)
        
        return section
    }
    
    // MARK: - Section 3: Teams Near You
    private func createTeamsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(90)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(285),
            heightDimension: .absolute(90)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16)
        
        // Add section header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    // MARK: - Section 4: Upcoming Events
    private func createEventsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(230)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.75),
            heightDimension: .absolute(230)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16)
        
        // Add section header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    // MARK: - Navigation Actions
    @IBAction func notificationsButtonTapped(_ sender: UIButton) {
        let vc = NotificationsViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func seeAllRolesButtonTapped(_ sender: UIButton) {
        let vc = ConnectionsViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func seeAllTeamsTapped() {
        print("See all teams tapped")
        // Navigate to teams list screen
    }
    
    private func seeAllEventsTapped() {
        print("See all events tapped")
        // Navigate to events list screen
    }
}

// MARK: - UICollectionView DataSource
extension ParticipantExploreViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5 // Main Header, Roles, Banner, Teams, Events
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 0 // Main header section has no cells
        case 1: return roles.count
        case 2: return partnerBanners.count
        case 3: return teams.count
        case 4: return events.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 1:
            // Roles Section
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoleCollectionViewCell", for: indexPath) as! RoleCollectionViewCell
            cell.configure(iconName: roleIcons[indexPath.item], title: roles[indexPath.item])
            return cell
            
        case 2:
            // Banner Section
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as! BannerCollectionViewCell
            cell.configure(imageURL: nil)
            return cell
            
        case 3:
            // Teams Section
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TeamCollectionViewCell", for: indexPath) as! TeamCollectionViewCell
            let team = teams[indexPath.item]
            cell.configure(teamName: team.name, membersCount: team.members, eventName: team.event)
            return cell
            
        case 4:
            // Events Section
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCardCell", for: indexPath) as! EventCardCell
            let event = events[indexPath.item]
            cell.titleLabel.text = event.title
            cell.dateLabel.text = event.date
            cell.venueLabel.text = event.venue
            cell.eventImageView.image = UIImage(named: event.image)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    // MARK: - Headers
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            
            // Section 0: Main Header (greeting + search)
            if indexPath.section == 0 {
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "HomeHeaderViewCollectionReusableView",
                    for: indexPath
                ) as! HomeHeaderViewCollectionReusableView
                
                // Get display name from profile
                let displayName = viewModel.profile?.displayName ?? "Guest"
                header.configure(userName: displayName)
                
                // Connect notification button action
                header.notificationButton.addTarget(self, action: #selector(notificationsButtonTapped(_:)), for: .touchUpInside)
                
                return header
            }
            
            // Sections 1, 3, 4: Section Headers with title + See All
            else {
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "SectionHeaderView",
                    for: indexPath
                ) as! SectionHeaderView
                
                switch indexPath.section {
                case 1:
                    header.configure(title: "Browse by Roles", showSeeAll: true)
                    header.seeAllAction = { [weak self] in
                        self?.seeAllRolesButtonTapped(UIButton())
                    }
                    
                case 3:
                    header.configure(title: "Open Teams Near You", showSeeAll: true)
                    header.seeAllAction = { [weak self] in
                        self?.seeAllTeamsTapped()
                    }
                    
                case 4:
                    header.configure(title: "Upcoming Events", showSeeAll: true)
                    header.seeAllAction = { [weak self] in
                        self?.seeAllEventsTapped()
                    }
                    
                default:
                    break
                }
                
                return header
            }
        }
        
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionView Delegate
extension ParticipantExploreViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            print("Selected role: \(roles[indexPath.item])")
        case 2:
            print("Selected partner banner")
        case 3:
            print("Selected team: \(teams[indexPath.item].name)")
        case 4:
            print("Selected event: \(events[indexPath.item].title)")
        default:
            break
        }
    }
}
