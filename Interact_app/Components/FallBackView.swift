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
    
    @IBOutlet weak var createEventButton: UIButton!
    
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
            createEventButton.isHidden = !showButton
            
            if showButton {
                createEventButton.addTarget(self, action: #selector(createEventButtonTapped), for: .touchUpInside)
            }
        }
        
        @objc private func createEventButtonTapped() {
            onCreateEventTapped?()
        }
    
}
