//
//  OngoingEventCard.swift
//  Interact-UIKit
//
//  Created by admin73 on 16/11/25.
//

import UIKit

class OngoingEventCard: UICollectionViewCell {
    
    // MARK: - Outlets

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var eventImage: UIImageView!

    @IBOutlet weak var eventName: UILabel!
    
    @IBOutlet weak var hoursLeft: UILabel!
  
    @IBOutlet weak var hoursToStartOrEndLabel: UILabel!
    
    @IBOutlet weak var eventState: UILabel!

    @IBOutlet weak var registrationsCount: UILabel!
    
    @IBOutlet weak var viewEventButton: ButtonComponent!
    
    // MARK: - Properties
    var onViewEventTapped: (() -> Void)?
    
    private var gradientLayer: CAGradientLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupButton()
        setupAppearance()
        eventImage.layer.cornerRadius = 5
        eventImage.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        DispatchQueue.main.async {
            self.applyGradient()
        }
    }
   
    func applyGradient() {
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true

        gradientLayer?.removeFromSuperlayer()

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.systemBlue.withAlphaComponent(0.3).cgColor,
            UIColor.systemYellow.withAlphaComponent(0.3).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = containerView.bounds
        gradient.cornerRadius = 16

        containerView.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }

    
    func configure(with event: UserEvent) {
        eventName.text = event.eventName ?? "Unnamed Event"
        registrationsCount.text = "\(event.registeredCount)"
        
        if let imageData = event.posterImageData, let image = UIImage(data: imageData) {
            eventImage.image = image
        } else {
            eventImage.image = UIImage(named: "events") ?? UIImage(systemName: "photo")
        }
        
        let (timeText, status) = calculateCardDetails(for: event)
        hoursLeft.text = timeText
        eventState.text = status
    }

    private func calculateCardDetails(for event: UserEvent) -> (timeText: String, status: String) {
        let now = Date()
        guard let startDate = event.startDate, let endDate = event.endDate else {
            hoursToStartOrEndLabel.text = "TBD"
            return ("Time TBD", "Scheduled")
        }
        
        if now < startDate {
            let hoursToStart = Int(startDate.timeIntervalSince(now) / 3600)
            hoursToStartOrEndLabel.text = "To Start"
            return ("\(hoursToStart) Hrs", "RSVP")
        } else {
            let hoursToEnd = Int(endDate.timeIntervalSince(now) / 3600)
            hoursToStartOrEndLabel.text = "Left"
            
            if hoursToEnd > 4 {
                return ("\(hoursToEnd) Hrs", "Live Now")
            } else {
                return ("\(hoursToEnd) Hrs", "Ending Soon")
            }
        }
    }
    
    private func setupButton() {
        viewEventButton.configure(title: "View Event", backgroundColor: .systemBlue)
        viewEventButton.onTap = { [weak self] in
            self?.onViewEventTapped?()
        }
    }
    
    private func setupAppearance() {
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.1
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
