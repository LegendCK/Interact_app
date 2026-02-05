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
    
    // MARK: - Properties
        private var eventId: UUID?
        
        // Callbacks
        var onRegisterTap: ((UUID, Bool) -> Void)?
        var onShareTap: ((UUID) -> Void)?
        
        private var isRegistered: Bool = false
            
        // MARK: - Lifecycle
        override func awakeFromNib() {
            super.awakeFromNib()
            // Allow shadows to be visible outside bounds
            self.clipsToBounds = false
            self.contentView.clipsToBounds = false
            setupUI()
        }
            
        override func prepareForReuse() {
            super.prepareForReuse()
            // Reset basic UI
            eventImage.image = nil
            eventTitle.text = nil
            eventDate.text = nil
            eventLocation.text = nil
            eventId = nil
            
            // Reset custom button closure to prevent reuse issues
            registerButton.onTap = nil
        }
            
        // MARK: - Setup
        private func setupUI() {
            eventTitle.numberOfLines = 2
            
            // Share Button (Standard UIButton)
            shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
                
            // Container Shadow
            containerView.layer.cornerRadius = 16
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
            containerView.layer.shadowRadius = 8
            containerView.layer.shadowOpacity = 0.2
            containerView.layer.masksToBounds = false
            containerView.backgroundColor = .white
                
            // Image Styling
            eventImage.layer.cornerRadius = 16
            // Only round top corners so it fits the card
            eventImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            eventImage.clipsToBounds = true
            eventImage.contentMode = .scaleAspectFill
        }
        
        // MARK: - Configuration Data Struct
        struct EventDisplayData {
            let id: UUID
            let imageUrl: String?
            let title: String
            let date: String
            let location: String
            let isRegistered: Bool
        }
        
        // MARK: - Configure Method
        func configure(with event: EventDisplayData) {
            self.eventId = event.id
            self.isRegistered = event.isRegistered
                
            // Text Data
            eventTitle.text = event.title
            eventDate.text = event.date
            eventLocation.text = event.location
                
            // Image Loading (Using the extension we created earlier)
            eventImage.loadImage(from: event.imageUrl, placeholder: UIImage(systemName: "photo"))
            
            // Configure Custom Button
            setupRegisterButtonState()
        }
        
        private func setupRegisterButtonState() {
//            let title = isRegistered ? "Registered" : "Register Now"
//            let bgColor = isRegistered ? UIColor.systemGreen : UIColor.systemBlue
//            let borderColor = isRegistered ? UIColor.systemGreen.withAlphaComponent(0.3) : nil
//            let borderWidth: CGFloat = isRegistered ? 1 : 0
            
            let title = "Register Now"
            let bgColor = UIColor.systemBlue
//            let borderColor = isRegistered ? UIColor.systemGreen.withAlphaComponent(0.3) : nil
//            let borderWidth: CGFloat = isRegistered ? 1 : 0
            
            // 1. Configure visual style using your Component's API
            registerButton.configure(
                title: title,
                titleColor: .white,
                backgroundColor: bgColor,
                cornerRadius: 8,
                font: .systemFont(ofSize: 16, weight: .semibold),
//                borderColor: borderColor,
//                borderWidth: borderWidth
            )
            
            // 2. Define the tap behavior
            registerButton.onTap = { [weak self] in
                guard let self = self, let id = self.eventId else { return }
                // Trigger the callback passing the ID and the new state (toggle)
                self.onRegisterTap?(id, !self.isRegistered)
            }
        }
        
        // MARK: - Actions
        @objc private func shareButtonTapped() {
            guard let eventId = eventId else { return }
            onShareTap?(eventId)
        }

}
