//
//  VerificationCard.swift
//  Interact-UIKit
//
//  Created by admin73 on 09/11/25.
//

import UIKit

class VerificationCard: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var verifyButton: ButtonComponent!
    
    // MARK: - Init Methods
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }

        // MARK: - Common Init (XIB Loader)
        private func commonInit() {
            let nibName = String(describing: type(of: self))
            let nib = UINib(nibName: nibName, bundle: nil)

            guard let contentView = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
            contentView.frame = bounds
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.layer.cornerRadius = 16
            contentView.clipsToBounds = true
            addSubview(contentView)

            // Gradient background
            DispatchQueue.main.async {
                self.applyGradientBackground(to: contentView)
            }

            // Configure button once the view is loaded
            DispatchQueue.main.async {
                self.configureButton()
            }
        }

        // MARK: - Gradient Setup
        private func applyGradientBackground(to view: UIView) {
            // Remove existing gradients to avoid stacking
            view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds
            gradientLayer.colors = [
                UIColor(red: 0.79, green: 0.91, blue: 1.0, alpha: 1.0).cgColor, // #C9E8FF
                UIColor(red: 1.0, green: 0.96, blue: 0.85, alpha: 1.0).cgColor  // #FFF6D9
            ]
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
            gradientLayer.cornerRadius = 16

            view.layer.insertSublayer(gradientLayer, at: 0)
        }

        // MARK: - Layout
        override func layoutSubviews() {
            super.layoutSubviews()
            // Ensure gradient resizes with the view
            if let gradientLayer = layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
                gradientLayer.frame = bounds
            }
        }

        // MARK: - Button Configuration
        private func configureButton() {
            verifyButton.configure(
                title: "Complete Verification",
                backgroundColor: .black,
                image: UIImage(systemName: "arrow.right"),
                imagePlacement: .trailing
            )

            verifyButton.onTap = {
                print("Verify Button tapped")
            }
        }

}
