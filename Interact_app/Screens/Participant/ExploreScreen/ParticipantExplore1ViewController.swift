import UIKit

final class ParticipantExplore1ViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var startCreatingTeamButton: ButtonComponent!
    @IBOutlet weak var rolesCollectionView: UICollectionView!
    @IBOutlet weak var upcomingEventsCollection: UICollectionView!
    
    @IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet weak var seeAllRolesButton: UIButton!
    
    // MARK: - Roles
    private let roles: [(String, String)] = [
        ("Designer", "paintpalette"),
        ("UI / UX", "scribble.variable"),
        ("Graphic Designer", "pencil.and.outline"),
        ("Product Designer", "cube.transparent"),
        ("Web Dev", "globe"),
        ("Frontend", "chevron.left.slash.chevron.right"),
        ("Backend", "server.rack"),
        ("Full Stack", "square.stack.3d.up"),
        ("App Dev", "iphone"),
        ("iOS", "applelogo"),
        ("Android", "antenna.radiowaves.left.and.right"),
        ("AI / ML", "brain.head.profile"),
        ("Data Sci", "chart.bar.xaxis"),
        ("DevOps", "gearshape.2"),
        ("Cloud", "cloud"),
        ("Cyber Sec", "lock.shield"),
        ("Blockchain", "cube"),
        ("Game Dev", "gamecontroller"),
        ("PM", "briefcase"),
        ("Tech Lead", "person.crop.rectangle.stack")
    ]

    // MARK: - Events
    struct Event {
        let image: UIImage?
        let title: String
        let datetime: String
        let venue: String
    }

    private let events: [Event] = [
        Event(
            image: UIImage(named: "events"),
            title: "Ossome Hacks 2.0",
            datetime: "Fri, 31 Oct 2025 · 9:00 am – 6:00 pm",
            venue: "SRMIST KTR, Chennai"
        ),
        Event(
            image: UIImage(named: "events"),
            title: "Ossome Hacks 2.0",
            datetime: "Fri, 31 Oct 2025 · 9:00 am – 6:00 pm",
            venue: "SRMIST KTR, Chennai"
        ),
        Event(
            image: UIImage(named: "events"),
            title: "Ossome Hacks 2.0",
            datetime: "Fri, 31 Oct 2025 · 9:00 am – 6:00 pm",
            venue: "SRMIST KTR, Chennai"
        )
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        startCreatingTeamButton.configure(
            title: "Start creating",
            backgroundColor: .black
        )

        setupRolesCollectionView()
        setupEventsCollectionView()
    }
    
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

}

// MARK: - Collection Setup
extension ParticipantExplore1ViewController {

    private func setupRolesCollectionView() {

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        rolesCollectionView.collectionViewLayout = layout
        rolesCollectionView.dataSource = self
        rolesCollectionView.backgroundColor = .clear
        rolesCollectionView.showsHorizontalScrollIndicator = false

        rolesCollectionView.register(
            UINib(nibName: "RoleShperesCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "RoleShperesCollectionViewCell"
        )
    }

    private func setupEventsCollectionView() {

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16)

        upcomingEventsCollection.collectionViewLayout = layout
        upcomingEventsCollection.dataSource = self
        upcomingEventsCollection.delegate = self
        upcomingEventsCollection.backgroundColor = .clear

        upcomingEventsCollection.register(
            UINib(nibName: "EventCardCell", bundle: nil),
            forCellWithReuseIdentifier: "EventCardCell"
        )
    }
}

// MARK: - DataSource
extension ParticipantExplore1ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        return collectionView == rolesCollectionView ? roles.count : events.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == rolesCollectionView {

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "RoleShperesCollectionViewCell",
                for: indexPath
            ) as! RoleShperesCollectionViewCell

            let role = roles[indexPath.item]
            cell.configure(
                role: role.0,
                icon: UIImage(systemName: role.1)
            )
            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "EventCardCell",
            for: indexPath
        ) as! EventCardCell

        let event = events[indexPath.item]
        cell.eventImageView.image = event.image
        cell.titleLabel.text = event.title
        cell.dateLabel.text = event.datetime
        cell.venueLabel.text = event.venue

        return cell
    }
}

// MARK: - Event Cell Size (ONLY for Events)
extension ParticipantExplore1ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard collectionView == upcomingEventsCollection else { return .zero }
        let width = collectionView.frame.width - 32
        return CGSize(width: width, height: 200)
    }
}
