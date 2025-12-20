//
//  ParticipantEventCard.swift
//  Interact_app
//
//  Created by admin73 on 15/12/25.
// layer.cornerRadius

import UIKit

class ParticipantEventCard: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var eventImage: UIImageView!
    
    @IBOutlet weak var eventTitle: UILabel!
    
    
    @IBOutlet weak var eventDate: UILabel!
    
    @IBOutlet weak var eventLocation: UILabel!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var registerButton: ButtonComponent!
    
    private var eventId: Int?
        var onRegisterTap: ((Int, Bool) -> Void)?
        var onShareTap: ((Int) -> Void)?
        
        override func awakeFromNib() {
            super.awakeFromNib()
            self.clipsToBounds = false
            self.contentView.clipsToBounds = false 
            setupUI()
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            eventImage.image = nil
            eventTitle.text = nil
            eventDate.text = nil
            eventLocation.text = nil
            eventId = nil
            registerButton.onTap = nil
        }
        
        private func setupUI() {
            eventTitle.numberOfLines = 2
            shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
            
//          // ✅ ADD SHADOW TO CONTAINER VIEW (Add this code)
            containerView.layer.cornerRadius = 16
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
            containerView.layer.shadowRadius = 8
            containerView.layer.shadowOpacity = 0.2
            containerView.layer.masksToBounds = false
            containerView.backgroundColor = .white
            
//            // Style image view
            eventImage.layer.cornerRadius = 16
            eventImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            eventImage.clipsToBounds = true
            eventImage.contentMode = .scaleAspectFill
        }
        
        func configure(with event: Event) {
            // Store event ID
            self.eventId = event.id
            
            // Set event data
            eventTitle.text = event.title
            eventDate.text = event.date
            eventLocation.text = event.location
            
            // Set event image
            if let image = UIImage(named: event.imageName) {
                eventImage.image = image
            } else {
                eventImage.image = UIImage(systemName: "calendar.badge.clock")
                eventImage.tintColor = .systemBlue
                eventImage.backgroundColor = .systemGray6
            }
            
            // Configure register button using ButtonComponent
            configureRegisterButton(for: event)
        }
        
        private func configureRegisterButton(for event: Event) {
            let isRegistered = event.isRegistered
            
            // Configure button appearance
            let buttonTitle = isRegistered ? "Registered" : "Register Now"
            let buttonColor = isRegistered ? UIColor.systemGreen : UIColor.systemBlue
            let titleColor = UIColor.white
            let borderColor = isRegistered ? UIColor.systemGreen.withAlphaComponent(0.3) : nil
            
            registerButton.configure(
                title: buttonTitle,
                titleColor: titleColor,
                backgroundColor: buttonColor,
                cornerRadius: 8,
                font: .systemFont(ofSize: 16, weight: .semibold),
                borderColor: borderColor,
                borderWidth: isRegistered ? 1 : 0
            )
            
            // Set button tap handler
            registerButton.onTap = { [weak self] in
                guard let self = self, let eventId = self.eventId else { return }
                self.onRegisterTap?(eventId, isRegistered)
            }
        }
        
        @objc private func shareButtonTapped() {
            guard let eventId = eventId else { return }
            onShareTap?(eventId)
        }
        
        // Helper struct to match the event model
        struct Event {
            let id: Int
            let imageName: String
            let title: String
            let date: String
            let location: String
            let isRegistered: Bool
        }

}
