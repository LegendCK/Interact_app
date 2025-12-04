//
//  VerificationCard.swift
//  Interact-UIKit
//
//  Created by admin73 on 09/11/25.
//

import UIKit

class VerificationCard: UIView {
    
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
        }

        // MARK: - Gradient Setup
        private func applyGradientBackground(to view: UIView) {
            // Remove existing gradients to avoid stacking
            view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds
            gradientLayer.colors = [
                UIColor.systemBlue.withAlphaComponent(0.25).cgColor,
                UIColor.systemYellow.withAlphaComponent(0.25).cgColor
//                  UIColor(hex: "#007AFF").withAlphaComponent(0.3).cgColor,
//                  UIColor(hex: "#34C759").withAlphaComponent(0.3).cgColor
            ]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
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
}

