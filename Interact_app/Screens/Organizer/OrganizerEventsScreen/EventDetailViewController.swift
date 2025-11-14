//
//  EventDetailViewController.swift
//  Interact-UIKit
//
//  Created by admin73 on 10/11/25.
//

//
//  EventDetailViewController.swift
//  Interact-UIKit
//
//  Created by admin73 on 10/11/25.
//

import UIKit

class EventDetailViewController: UIViewController {

    @IBOutlet weak var eventImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var venueLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var viewRegistrationsButton: ButtonComponent!
    
    @IBOutlet weak var viewRSVPButton: ButtonComponent!
    
   
    @IBOutlet weak var whatsappGrpButton: ButtonComponent!
    
    var event: EventsScreenViewController.Event!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewRegistrationsButton.configure(
            title: "View Registrations",
            backgroundColor: .systemBlue,
            image: UIImage(systemName: "list.bullet.clipboard"),
            imagePlacement: .leading
        )
        
        viewRegistrationsButton.onTap = {
            print("Scan QR Button tapped")
        }
       
        viewRSVPButton.configure(
            title: " View RSVP",
            backgroundColor: .systemYellow,
            image: UIImage(systemName: "calendar.badge.checkmark"),
            imagePlacement: .leading
        )
        
        viewRSVPButton.onTap = {
            print("Scan QR Button tapped")
        }
        
        whatsappGrpButton.configure(
            title: "Join Whatsapp Group",
            backgroundColor: .systemGreen,
            image: UIImage(systemName: "bubble"),
            imagePlacement: .leading
        )
        
        whatsappGrpButton.onTap = { [weak self] in
            // 1. Check if self exists and if the URL is available and valid
            guard let self = self,
                  let url = self.event.whatsappGrpLink else { // Access the URL directly
                print("Error: WhatsApp group link is missing or invalid for this event.")
                return
            }
            
            // 2. Open the URL externally
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    print("Successfully opened WhatsApp group link: \(url.absoluteString)")
                } else {
                    print("Failed to open WhatsApp group link.")
                }
            }
        }
        
        setupUI()
    }

    private func setupUI() {
//        title = "Event Details"
        eventImageView.image = event.image
        titleLabel.text = event.title
        dateLabel.text = event.datetime
        venueLabel.text = event.venue
        descriptionLabel.text = event.description

        // Button visibility logic
        switch event.status {
        case .past:
            viewRegistrationsButton.isHidden = true
            viewRSVPButton.isHidden = true
        case .upcoming:
            viewRegistrationsButton.isHidden = false
            viewRSVPButton.isHidden = true
        case .ongoing:
            viewRegistrationsButton.isHidden = false
            viewRSVPButton.isHidden = false
        }

        
    }
}
