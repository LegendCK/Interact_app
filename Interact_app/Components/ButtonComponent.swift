//
//  ButtonComponent.swift
//  Interact-UIKit
//
//  Created by admin73 on 08/11/25.
//

import UIKit

class ButtonComponent: UIView {

    @IBOutlet weak var button: UIButton!
    
    var onTap: (() -> Void)?
    
    var isEnabled: Bool {
            get {
                return button.isEnabled
            }
            set {
                button.isEnabled = newValue
                // Optional: Adjust opacity for visual feedback
                // Since you use UIButton.Configuration, the button will likely
                // dim automatically, but setting alpha ensures the whole view looks disabled.
                self.alpha = newValue ? 1.0 : 0.6
            }
        }
        
        // MARK: - Init
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
        
        private func commonInit() {
            let nib = UINib(nibName: "ButtonComponent", bundle: nil)
            guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
            view.frame = bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(view)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
    
    func updateTitle(_ title: String) {
            // We must modify the existing configuration to preserve fonts/icons
            guard var config = button.configuration else { return }
            config.title = title
            button.configuration = config
        }

        func updateBackgroundColor(_ color: UIColor) {
            guard var config = button.configuration else { return }
            config.baseBackgroundColor = color
            button.configuration = config
        }
    
        
        // MARK: - Configure method
    func configure(
        title: String,
        titleColor: UIColor = .white,
        backgroundColor: UIColor = .systemBlue,
        cornerRadius: CGFloat = 10,
        font: UIFont = .systemFont(ofSize: 16, weight: .medium),
        image: UIImage? = nil,
        imagePlacement: NSDirectionalRectEdge = .leading, // .leading or .trailing
        imagePadding: CGFloat = 8,
        contentInsets: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20),
        borderColor: UIColor? = nil,
        borderWidth: CGFloat = 0
    ) {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = backgroundColor
        config.baseForegroundColor = titleColor
        config.title = title
        config.cornerStyle = .medium
        config.contentInsets = contentInsets

        if let image = image {
            config.image = image
            config.imagePlacement = imagePlacement
            config.imagePadding = imagePadding
        }

        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = font
            return outgoing
        }

        // Apply configuration
        button.configuration = config
        button.layer.cornerRadius = cornerRadius
        button.clipsToBounds = true
        
        if let borderColor = borderColor {
                button.layer.borderColor = borderColor.cgColor
                button.layer.borderWidth = borderWidth
            } else {
                button.layer.borderWidth = 0
            }
    }

    
    @IBAction func buttonTapped(_ sender: UIButton) {
        onTap?()
    }
    
}
