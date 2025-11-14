//
//  SignupViewController.swift
//  Interact_app
//
//  Created by admin56 on 07/11/25.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var organizationNameTextField: UITextField!
    @IBOutlet weak var organizationEmailAddressTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var createPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var verifyEmailButton: ButtonComponent!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFields()
        verifyEmailButton.configure(title: "Verify Email")
        verifyEmailButton.onTap = {
            let verifyAccountVC = VerifyAccountViewController(nibName: "VerifyAccountViewController", bundle: nil)
            self.navigationController?.pushViewController(verifyAccountVC, animated: true)
        }
        // Do any additional setup after loading the view.
    }
    
    private func setupTextFields() {
            let textFields = [
                organizationNameTextField,
                organizationEmailAddressTextField,
                mobileNumberTextField,
                createPasswordTextField,
                confirmPasswordTextField
                
            ]
            
            for textField in textFields {
                guard let field = textField else { continue }
                field.delegate = self
                
                field.borderStyle = .none
                field.layer.borderColor = UIColor.systemGray4.cgColor
                field.layer.borderWidth = 1
                field.layer.cornerRadius = 10
                
                let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.height))
                field.leftView = leftPaddingView
                field.leftViewMode = .always
            }
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
