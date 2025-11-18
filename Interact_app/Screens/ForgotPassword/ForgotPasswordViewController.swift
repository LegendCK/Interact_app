//
//  ForgotPasswordViewController.swift
//  Interact_app
//
//  Created by admin56 on 07/11/25.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var backToLoginLable: UILabel!
    @IBOutlet weak var sendResetLinkButton: ButtonComponent!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendResetLinkButton.configure(
            title: "Send reset link"
        )
        
        sendResetLinkButton.onTap = {
            let resetPasswordVC = NewPasswordViewController(nibName: "NewPasswordViewController", bundle: nil)
            self.navigationController?.pushViewController(resetPasswordVC, animated: true)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backToLoginTapped))
            backToLoginLable.isUserInteractionEnabled = true
            backToLoginLable.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.
    }
    
    @objc func backToLoginTapped() {
        goToLoginScreen()
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
