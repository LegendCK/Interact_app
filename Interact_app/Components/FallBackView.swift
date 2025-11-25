//
//  FallBackView.swift
//  Interact-UIKit
//
//  Created by admin73 on 19/11/25.
//

import UIKit

class FallBackView: UIView {

    @IBOutlet weak var fallBackImage: UIImageView!
    
    @IBOutlet weak var fallBackMessage: UILabel!
    
    @IBOutlet weak var createNewEventButton: ButtonComponent!
    
    @IBOutlet weak var createEventLabel: UILabel!
    
    var onCreateEventTapped: (() -> Void)?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
        
        private func commonInit() {
            let bundle = Bundle(for: type(of: self))
            let nib = UINib(nibName: "FallBackView", bundle: bundle)
            let contentView = nib.instantiate(withOwner: self, options: nil).first as! UIView
            contentView.frame = bounds
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(contentView)
        }
        
        func configure(message: String, showButton: Bool = false) {
            fallBackMessage.text = message
            createNewEventButton.isHidden = !showButton
            createEventLabel.isHidden = !showButton
            
            if showButton {
                createNewEventButton.configure(
                    title: "Create Event",
                    titleColor: .white,
                    backgroundColor: .systemBlue,
                )
                
                createNewEventButton.onTap = { [weak self] in
                    self?.onCreateEventTapped?()
                }
            }
        }
}
