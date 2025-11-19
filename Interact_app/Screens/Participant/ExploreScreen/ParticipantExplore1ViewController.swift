//
//  ParticipantExplore1ViewController.swift
//  Interact_app
//
//  Created by admin56 on 17/11/25.
//

import UIKit

class ParticipantExplore1ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var startCreatingTeamButton: ButtonComponent!
    @IBOutlet weak var upcomingEventsCollection: UICollectionView!
    @IBOutlet weak var rolesCollectionView: UICollectionView!
    
    
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
            image: UIImage(named: "events"),
            title: "Ossome Hacks 2.0",
            datetime: "Fri, 31 Oct 2025 · 9:00 am – 6:00 pm",
            venue: "SRMIST KTR, Chennai, Tamil Nadu",
            status: .active
        ),
        Event(
            image: UIImage(named: "events"),
            title: "AI Innovation Summit 2025",
            datetime: "Mon, 21 Jul 2025 · 10:00 am – 5:00 pm",
            venue: "Chennai Trade Center",
            status: .ended
        ),
        Event(
            image: UIImage(named: "events"),
            title: "HackFest 2026",
            datetime: "Fri, 15 Jan 2026 · 9:00 am – 9:00 pm",
            venue: "Bangalore Tech Park",
            status: .active
        ),
        Event(
            image: UIImage(named: "events"),
            title: "HackFest 2026",
            datetime: "Fri, 15 Jan 2026 · 9:00 am – 9:00 pm",
            venue: "Bangalore Tech Park",
            status: .active
        ),
        Event(
            image: UIImage(named: "events"),
            title: "HackFest 2026",
            datetime: "Fri, 15 Jan 2026 · 9:00 am – 9:00 pm",
            venue: "Bangalore Tech Park",
            status: .active
        ),
        Event(
            image: UIImage(named: "events"),
            title: "HackFest 2026",
            datetime: "Fri, 15 Jan 2026 · 9:00 am – 9:00 pm",
            venue: "Bangalore Tech Park",
            status: .active
        ),
        Event(
            image: UIImage(named: "events"),
            title: "HackFest 2026",
            datetime: "Fri, 15 Jan 2026 · 9:00 am – 9:00 pm",
            venue: "Bangalore Tech Park",
            status: .active
        )
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startCreatingTeamButton.configure(
            title: "Start creating",
            backgroundColor: UIColor.black
        )
        setupCollectionView()

        // Do any additional setup after loading the view.
    }
    
    func setupCollectionView() {
        // Register your custom EventCardCell from XIB
        let nib = UINib(nibName: "EventCardCell", bundle: nil)
        upcomingEventsCollection.register(nib, forCellWithReuseIdentifier: "EventCardCell")
        upcomingEventsCollection.dataSource = self
        upcomingEventsCollection.delegate = self
        upcomingEventsCollection.backgroundColor = .clear
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Rendering cell for \(events[indexPath.item].title)")
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCardCell", for: indexPath) as? EventCardCell else {
            return UICollectionViewCell()
        }
        let event = events[indexPath.item]
        // Use your IBOutlets in EventCardCell to set data
        cell.eventImageView.image = event.image
        cell.titleLabel.text = event.title
        cell.dateLabel.text = event.datetime
        cell.venueLabel.text = event.venue
        // Customize share button as needed
        cell.shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let horizontalInset: CGFloat = 16
        let availableWidth = collectionView.frame.width - (horizontalInset * 2)
        
        // Maintain your card’s aspect ratio
        let aspectRatio: CGFloat = 200 / 320
        var height = availableWidth * aspectRatio
        
        // ✅ Cap the height so it doesn't grow too tall on iPads or landscape
        let maxHeight: CGFloat = 230
        let minHeight: CGFloat = 180
        height = min(maxHeight, max(minHeight, height))
        
        return CGSize(width: availableWidth, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
