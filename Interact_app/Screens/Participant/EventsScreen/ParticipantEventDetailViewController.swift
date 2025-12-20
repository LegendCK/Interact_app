//
//  ParticipantEventDetailViewController.swift
//  Interact_app
//
//  Created by admin73 on 15/12/25.
//

import UIKit

class ParticipantEventDetailViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet weak var registerButton: ButtonComponent!
    @IBOutlet weak var eventImage: UIImageView!
    
    @IBOutlet weak var eventName: UILabel!
    
    @IBOutlet weak var eventStartDate: UILabel!
    
    @IBOutlet weak var eventEndDate: UILabel!
    
    @IBOutlet weak var eventLocation: UILabel!
    
    @IBOutlet weak var infoContainerView: UIView!
    
    @IBOutlet weak var organizerInfoContainerView: UIView!
    
    @IBOutlet weak var detailsContainerView: UIView!
    
    var event: ParticipantEventsViewController.Event?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInfo()
        setupUI()
    }
    
    
    private func setupInfo() {
        eventImage.image = UIImage(named: event!.imageName)
        eventName.text = event!.title
        eventStartDate.text = "\(event!.startDate)"
        eventEndDate.text = "\(event!.endDate)"
        eventLocation.text = event!.location
    }
    
    private func setupUI() {
        infoContainerView.layer.cornerRadius = 10
        organizerInfoContainerView.layer.cornerRadius = 10
        detailsContainerView.layer.cornerRadius = 10
        eventImage.layer.cornerRadius = 10
        containerView.backgroundColor = UIColor(hex: "#007AFF").withAlphaComponent(0.1)
        
        registerButton.configure(
            title: "Register",
            titleColor: .white,
            backgroundColor: .systemBlue,
            cornerRadius: 8,
            font: .systemFont(ofSize: 16, weight: .semibold),
        )
        
        
//        infoContainerView.layer.cornerRadius = 16
//        infoContainerView.layer.shadowColor = UIColor.black.cgColor
//        infoContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        infoContainerView.layer.shadowRadius = 8
//        infoContainerView.layer.shadowOpacity = 0.1
//        infoContainerView.layer.masksToBounds = false
//        infoContainerView.backgroundColor = .white
//        
//        organizerInfoContainerView.layer.cornerRadius = 16
//        organizerInfoContainerView.layer.shadowColor = UIColor.black.cgColor
//        organizerInfoContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        organizerInfoContainerView.layer.shadowRadius = 8
//        organizerInfoContainerView.layer.shadowOpacity = 0.1
//        organizerInfoContainerView.layer.masksToBounds = false
//        organizerInfoContainerView.backgroundColor = .white
//        
//        detailsContainerView.layer.cornerRadius = 16
//        detailsContainerView.layer.shadowColor = UIColor.black.cgColor
//        detailsContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        detailsContainerView.layer.shadowRadius = 8
//        detailsContainerView.layer.shadowOpacity = 0.1
//        detailsContainerView.layer.masksToBounds = false
//        detailsContainerView.backgroundColor = .white
    }
    
//    // MARK: - Setup Method
//    func configure(with event: ParticipantEventsViewController.Event) {
//        self.event = event
//    }
}
