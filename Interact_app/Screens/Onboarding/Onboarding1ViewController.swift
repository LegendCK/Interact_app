//
//  Onboarding1ViewController.swift
//  Interact_app
//
//  Created by admin56 on 09/11/25.
//

import UIKit

class Onboarding1ViewController: UIViewController {

    @IBOutlet weak var onboardingImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var skipButton: UIButton!
    
    var imageName: String?
        var titleText: String?
        var descText: String?
        var showSkipButton: Bool = true

        override func viewDidLoad() {
            super.viewDidLoad()

            onboardingImage.image = UIImage(named: imageName ?? "")
            titleLabel.text = titleText
            descLabel.text = descText
            skipButton.isHidden = !showSkipButton
        }
    
    @IBAction func skipTapped(_ sender: UIButton) {
            // User wants to skip onboarding entirely
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")

            let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
            navigationController?.setViewControllers([loginVC], animated: true)
        }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
