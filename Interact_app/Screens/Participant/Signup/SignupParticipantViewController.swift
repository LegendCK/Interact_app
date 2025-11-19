//
//  SignupParticipantViewController.swift
//  Interact_app
//
//  Created by admin56 on 07/11/25.
//

//
//  SignupParticipantViewController.swift
//  Interact_app
//

import UIKit

class SignupParticipantViewController: UIViewController {

    // Role passed from RoleSelectionViewController
    var userRole: UserRole?

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var middleNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var createPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var verifyEmailButton: ButtonComponent!

    override func viewDidLoad() {
        super.viewDidLoad()

        verifyEmailButton.configure(title: "Verify Email")

        verifyEmailButton.onTap = { [weak self] in
            guard let self else { return }

            let verifyVC = VerifyAccountViewController(
                nibName: "VerifyAccountViewController",
                bundle: nil
            )

            verifyVC.userRole = .participant   // ⬅ IMPORTANT
            self.navigationController?.pushViewController(verifyVC, animated: true)
        }
    }
}

