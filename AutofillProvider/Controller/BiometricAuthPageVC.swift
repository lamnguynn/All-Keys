//
//  BiometricAuthPageVC.swift
//  CredentialProvider
//
//  Created by Lam Nguyen on 7/8/21.
//

import UIKit
import LocalAuthentication

class BiometricAuthPageVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        //Authenticate with biometric
        authenticateWithBio()
    }
    
    func authenticateWithBio(){
        let context = LAContext()
        var error: NSError? = nil
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error){
            //Authentication passed
            let reason = "Please authenticate to continue!"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, error in
                DispatchQueue.main.async { [self] in
                    guard success, error == nil else{
                        self!.authenticateWithBio()
                        return
                    }
                    self?.view.endEditing(true)
                    self?.performSegue(withIdentifier: "showCredential", sender: self)
                }
            }
            
        }
        else{
            //Authentication failed
            let alertController = UIAlertController(title: "Unavailable", message: "Cannot use this feature", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    


}
