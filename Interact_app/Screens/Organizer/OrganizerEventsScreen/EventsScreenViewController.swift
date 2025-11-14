//
//  EventsScreenViewController.swift
//  Interact-UIKit
//
//  Created by admin73 on 07/11/25.
//

import UIKit
import Foundation

class EventsScreenViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {


    @IBOutlet weak var searchBar: UISearchBar!
   
    @IBOutlet weak var segmentedControl: UISegmentedControl!
       
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var filteredEvents: [Event] = []
        var currentSegmentIndex: Int = 0

        // MARK: - Event Model
        enum EventStatus {
            case upcoming
            case ongoing
            case past
        }

        struct Event {
            let image: UIImage?
            let title: String
            let datetime: String
            let venue: String
            let status: EventStatus
            let description: String
            let whatsappGrpLink: URL?
        }

        // MARK: - Mock Events
        let events: [Event] = [
            Event(
                image: UIImage(named: "events"),
                title: "TechX 2025",
                datetime: "Wed, 10 Dec 2025 · 9:00 am – 5:00 pm",
                venue: "SRMIST Auditorium",
                status: .upcoming,
                description: "A national-level technology symposium showcasing the latest innovations.",
                whatsappGrpLink: URL(string: "https://studique.in")
            ),
            Event(
                image: UIImage(named: "events"),
                title: "Cultural Fest 2025",
                datetime: "Fri, 7 Nov 2025 · 10:00 am – 6:00 pm",
                venue: "Main Grounds, SRMIST",
                status: .ongoing,
                description: "An ongoing cultural celebration filled with performances, music, and dance.",
                whatsappGrpLink: URL(string: "https://studique.in")
            ),
            Event(
                image: UIImage(named: "events"),
                title: "AI Innovation Summit 2024",
                datetime: "Mon, 15 July 2024 · 9:00 am – 4:00 pm",
                venue: "Chennai Trade Center",
                status: .past,
                description: "A concluded event that gathered leading AI researchers and innovators.",
                whatsappGrpLink: URL(string: "https://chat.whatsapp.com/BS5IYJquMyuCKaBeImN6K6")
            ),
            Event(
                image: UIImage(named: "events"),
                title: "Design Sprint Challenge",
                datetime: "Tue, 25 Nov 2025 · 9:00 am – 6:00 pm",
                venue: "SRM Design Lab",
                status: .upcoming,
                description: "Collaborative design challenge focused on UX/UI problem-solving.",
                whatsappGrpLink: URL(string: "https://studique.in")
            )
        ]

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupGradientBackground()
            setupCollectionView()
            setupSegmentedControl()
            searchBar.delegate = self
            filteredEvents = events
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            view.layer.sublayers?.first?.frame = view.bounds
        }

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
            let segments = ["All", "Upcoming", "Ongoing", "Past"]
            for (index, title) in segments.enumerated() {
                segmentedControl.insertSegment(withTitle: title, at: index, animated: false)
            }
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        }

        // MARK: - Filter Logic
        @objc func segmentChanged(_ sender: UISegmentedControl) {
            currentSegmentIndex = sender.selectedSegmentIndex
            applyFilters()
        }

        func applyFilters(searchText: String = "") {
            var filtered = events
            switch currentSegmentIndex {
            case 1:
                filtered = filtered.filter { $0.status == .upcoming }
            case 2:
                filtered = filtered.filter { $0.status == .ongoing }
            case 3:
                filtered = filtered.filter { $0.status == .past }
            default:
                break
            }
            
            if !searchText.isEmpty {
                filtered = filtered.filter {
                    $0.title.lowercased().contains(searchText.lowercased())
                }
            }
            filteredEvents = filtered
            collectionView.reloadData()
        }

        // MARK: - Collection View
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            filteredEvents.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCardCell", for: indexPath) as? EventCardCell else {
                return UICollectionViewCell()
            }
            let event = filteredEvents[indexPath.item]
            cell.eventImageView.image = event.image
            cell.titleLabel.text = event.title
            cell.dateLabel.text = event.datetime
            cell.venueLabel.text = event.venue
            cell.shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
            return cell
        }

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
            let detailVC = EventDetailViewController()
            detailVC.event = selectedEvent
            navigationController?.pushViewController(detailVC, animated: true)
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
