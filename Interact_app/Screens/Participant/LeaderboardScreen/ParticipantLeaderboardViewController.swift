//
//  ParticipantLeaderboardViewController.swift
//  Interact_app
//
//  Created by admin56 on 17/11/25.
//

import UIKit

class ParticipantLeaderboardViewController: UIViewController {
    
    @IBOutlet weak var rankOneView: UIView!
    @IBOutlet weak var rankOneHeading: UIView!
    @IBOutlet weak var rankOneImage: UIImageView!
    @IBOutlet weak var rankOneName: UILabel!
    @IBOutlet weak var rankOnePoints: UILabel!
    
    @IBOutlet weak var rankTwoView: UIView!
    @IBOutlet weak var rankTwoHeading: UIView!
    @IBOutlet weak var rankTwoImage: UIImageView!
    @IBOutlet weak var rankTwoPoints: UILabel!
    @IBOutlet weak var rankTwoName: UILabel!
    
    @IBOutlet weak var rankThreePoints: UILabel!
    @IBOutlet weak var rankThreeName: UILabel!
    @IBOutlet weak var rankThreeView: UIView!
    @IBOutlet weak var rankThreeHeading: UIView!
    @IBOutlet weak var rankThreeImage: UIImageView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Data Models
    struct Participant {
        let rank: Int
        let name: String
        let wins: Int
        let participations: Int
        let points: Int
        let image: UIImage?
    }
    
    struct Team {
        let rank: Int
        let name: String
        let wins: Int
        let participations: Int
        let points: Int
        let image: UIImage?
        let members: Int
    }
    
    // MARK: - Data Sources
    private var participants: [Participant] = [
        Participant(rank: 1, name: "Chirag Khairnar", wins: 18, participations: 25, points: 820, image: UIImage(named: "ProfileImage")),
        Participant(rank: 2, name: "Aashvi Swaroop", wins: 16, participations: 22, points: 760, image: UIImage(named: "ProfileImage")),
        Participant(rank: 3, name: "Gaurav Mishra", wins: 14, participations: 21, points: 710, image: UIImage(named: "ProfileImage")),
        Participant(rank: 4, name: "Sneha Iyer", wins: 12, participations: 19, points: 650, image: UIImage(named: "ProfileImage")),
        Participant(rank: 5, name: "Rohit Verma", wins: 11, participations: 18, points: 620, image: UIImage(named: "ProfileImage")),
        Participant(rank: 6, name: "Ananya Singh", wins: 10, participations: 17, points: 590, image: UIImage(named: "ProfileImage")),
        Participant(rank: 7, name: "Arjun Rao", wins: 9, participations: 16, points: 560, image: UIImage(named: "ProfileImage")),
        Participant(rank: 8, name: "Priya Nair", wins: 8, participations: 15, points: 530, image: UIImage(named: "ProfileImage")),
        Participant(rank: 9, name: "Vikram Joshi", wins: 7, participations: 14, points: 500, image: UIImage(named: "ProfileImage")),
        Participant(rank: 10, name: "Meera Desai", wins: 6, participations: 13, points: 470, image: UIImage(named: "ProfileImage")),
        Participant(rank: 11, name: "Rajesh Kumar", wins: 5, participations: 12, points: 440, image: UIImage(named: "ProfileImage"))
    ]
    
    private var teams: [Team] = [
        Team(rank: 1, name: "Alpha Squad", wins: 22, participations: 30, points: 950, image: UIImage(named: "teamProfileImage"), members: 5),
        Team(rank: 2, name: "Beta Warriors", wins: 20, participations: 28, points: 890, image: UIImage(named: "teamProfileImage"), members: 4),
        Team(rank: 3, name: "Gamma Titans", wins: 18, participations: 25, points: 830, image: UIImage(named: "teamProfileImage"), members: 6),
        Team(rank: 4, name: "Delta Legends", wins: 16, participations: 24, points: 780, image: UIImage(named: "teamProfileImage"), members: 5),
        Team(rank: 5, name: "Epsilon Heroes", wins: 15, participations: 22, points: 740, image: UIImage(named: "teamProfileImage"), members: 4),
        Team(rank: 6, name: "Zeta Champions", wins: 13, participations: 20, points: 690, image: UIImage(named: "teamProfileImage"), members: 5),
        Team(rank: 7, name: "Theta Mavericks", wins: 12, participations: 19, points: 650, image: UIImage(named: "teamProfileImage"), members: 6),
        Team(rank: 8, name: "Iota Vikings", wins: 11, participations: 18, points: 620, image: UIImage(named: "teamProfileImage"), members: 4),
        Team(rank: 9, name: "Kappa Spartans", wins: 10, participations: 17, points: 590, image: UIImage(named: "teamProfileImage"), members: 5),
        Team(rank: 10, name: "Lambda Eagles", wins: 9, participations: 16, points: 560, image: UIImage(named: "teamProfileImage"), members: 6),
        Team(rank: 11, name: "Sigma Phoenix", wins: 8, participations: 15, points: 530, image: UIImage(named: "teamProfileImage"), members: 5)
    ]
    
    // MARK: - Computed Properties
    private var currentMode: LeaderboardMode {
        LeaderboardMode(rawValue: segmentedControl.selectedSegmentIndex) ?? .individual
    }
    
    private var currentTopThree: [Any] {
        switch currentMode {
        case .individual:
            return Array(participants.prefix(3))
        case .team:
            return Array(teams.prefix(3))
        }
    }
    
    private var currentRemainingItems: [Any] {
        switch currentMode {
        case .individual:
            return Array(participants.dropFirst(3))
        case .team:
            return Array(teams.dropFirst(3))
        }
    }
    
    // MARK: - Enums
    enum LeaderboardMode: Int {
        case individual = 0
        case team = 1
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControl()
        setupTopThree()
        setupCollectionView()
    }
    
    // MARK: - Setup Methods
    private func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
    }
    
    private func setupTopThree() {
        updateTopThreeDisplay()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let nib = UINib(nibName: "RankCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "RankCell")
        
        collectionView.backgroundColor = UIColor(hex: "#007AFF").withAlphaComponent(0.1)
        collectionView.layer.cornerRadius = 16
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collectionView.layer.masksToBounds = true
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
        }
    }
    
    // MARK: - Top 3 Display Update
    private func updateTopThreeDisplay() {
        let topThree = currentTopThree
        
        // Configure Rank 1
        if let first = topThree[safe: 0] {
            configureRankView(
                rankOneView,
                headingView: rankOneHeading,
                imageView: rankOneImage,
                nameLabel: rankOneName,
                pointsLabel: rankOnePoints,
                item: first,
                borderColor: UIColor(hex: "#FFD700")
            )
        }
        
        // Configure Rank 2
        if let second = topThree[safe: 1] {
            configureRankView(
                rankTwoView,
                headingView: rankTwoHeading,
                imageView: rankTwoImage,
                nameLabel: rankTwoName,
                pointsLabel: rankTwoPoints,
                item: second,
                borderColor: UIColor(hex: "#9B8AFB")
            )
        }
        
        // Configure Rank 3
        if let third = topThree[safe: 2] {
            configureRankView(
                rankThreeView,
                headingView: rankThreeHeading,
                imageView: rankThreeImage,
                nameLabel: rankThreeName,
                pointsLabel: rankThreePoints,
                item: third,
                borderColor: UIColor(hex: "#CD7F32")
            )
        }
    }
    
    private func configureRankView(
        _ view: UIView,
        headingView: UIView,
        imageView: UIImageView,
        nameLabel: UILabel,
        pointsLabel: UILabel,
        item: Any,
        borderColor: UIColor
    ) {
        // Apply common styling
        headingView.layer.cornerRadius = headingView.frame.height / 2
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.layer.borderWidth = 5
        imageView.layer.borderColor = borderColor.cgColor
        headingView.layer.backgroundColor = borderColor.cgColor
        imageView.clipsToBounds = true
        
        // Configure based on item type
        if let participant = item as? Participant {
            nameLabel.text = participant.name
            pointsLabel.text = "\(participant.points)"
            imageView.image = participant.image ?? UIImage(named: "placeholder_profile")
        } else if let team = item as? Team {
            nameLabel.text = team.name
            pointsLabel.text = "\(team.points)"
            imageView.image = team.image ?? UIImage(named: "placeholder_profile")
        }
    }
    
    // MARK: - Actions
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        updateTopThreeDisplay()
        collectionView.reloadData()
    }
}

// MARK: - UICollectionView DataSource
extension ParticipantLeaderboardViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentRemainingItems.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "RankCell",
            for: indexPath
        ) as? RankCell else {
            return UICollectionViewCell()
        }
        
        let item = currentRemainingItems[indexPath.item]
        
        if let participant = item as? Participant {
            cell.configure(
                rank: participant.rank,
                name: participant.name,
                wins: participant.wins,
                participations: participant.participations,
                points: participant.points,
                image: participant.image
            )
        } else if let team = item as? Team {
            cell.configure(
                rank: team.rank,
                name: "\(team.name)",
                wins: team.wins,
                participations: team.participations,
                points: team.points,
                image: team.image
            )
        }
        
        return cell
    }
}

// MARK: - UICollectionView Delegate FlowLayout
extension ParticipantLeaderboardViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        return CGSize(
            width: collectionView.frame.width - 32, // Adjusted for better spacing
            height: 70
        )
    }
}

// MARK: - Safe Array Indexing
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
