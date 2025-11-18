//
//  TermsAndConditionViewController.swift
//  Interact_app
//
//  Created by admin56 on 18/11/25.
//

import UIKit

class TermsAndConditionViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var acceptAndContinueButton: ButtonComponent!
    @IBOutlet weak var scrollView: UIScrollView!

    var onAccept: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self

        // Configure button
        acceptAndContinueButton.configure(
            title: "Accept & Continue",
            backgroundColor: .systemBlue
        )

        // Disable button by default
        setButtonEnabled(false)

        // Handle tap
        acceptAndContinueButton.onTap = { [weak self] in
            guard let self else { return }
            self.onAccept?()
            self.dismiss(animated: true)
        }
    }

    // MARK: - Scroll Detection
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let visibleHeight = scrollView.frame.size.height
        let contentHeight = scrollView.contentSize.height

        if offsetY + visibleHeight >= contentHeight - 10 {
            setButtonEnabled(true)
        }
    }

    private func setButtonEnabled(_ enabled: Bool) {
        acceptAndContinueButton.button.isEnabled = enabled
        acceptAndContinueButton.alpha = enabled ? 1.0 : 0.5
    }
}
