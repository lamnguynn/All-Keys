//
//  SceneDelegate.swift
//  TestingBio
//
//  Created by Lam Nguyen on 6/16/21.
//

import UIKit
import LocalAuthentication

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.

        //If the authentication is not the initial (app first opened), then any animation transaction(s) can happen. Avoids any collisions
        let notInitialAuthentation = initalAuthentation
        if notInitialAuthentation && !needPassword{
            self.privacyWindow?.isHidden = true
            self.privacyWindow = nil
            self.initalAuthentation = true
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        
        //If the authentication is not the initial (app first opened), then any animation transaction(s) can happen. Avoids any collisions
        let notInitialAuthentation = initalAuthentation
        if notInitialAuthentation && !infoDeleteState.deleting{
            showPrivacyScreen()
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
        hidePrivacyScreen()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        showPrivacyScreen()
    }

    //MARK: privacy protection
    
    private var privacyWindow: UIWindow!                    //Window to hold the privacy screeen
    private var initalAuthentation: Bool = false            //Bool to hold if the user just opened the app fresh
    private var needPassword: Bool = false                  //Bool to hold if a password is prompted because of failure of biometrics
    
    /*
     Show the privacy screen by calling the privacy screen view controller
     */
    private func showPrivacyScreen(){
        guard let windowScene = self.window?.windowScene else{
            return
        }
        
        privacyWindow = UIWindow(windowScene: windowScene)
        privacyWindow?.rootViewController = PrivacyScreenVC()
        privacyWindow?.windowLevel = .alert + 1
        privacyWindow?.makeKeyAndVisible()
    }
    
    /*
     Hides the privacy screen by using biometrics/password
     */
    func hidePrivacyScreen(){
        if !initalAuthentation{
            //If initially not authenticated (first opened), then show the privacy screen
            showPrivacyScreen()
        }
        
        //If the app is intially opened, shoe the privacy screen
        //Use Biometrics to authenticate
        let context = LAContext()
        var error: NSError? = nil
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error){
            //Authentication passed
            let reason = "Please enter authenticate to continue!"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, error in
                DispatchQueue.main.async { [self] in
                    guard success, error == nil else{
                        //Add a button to reauthenticate in case of intiial failure
                        self?.needPassword = true
                        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
                        button.center = (self?.privacyWindow.center)!
                        button.setTitle("Unlock", for: .normal)
                        button.backgroundColor = UIColor(red: 76/255, green: 175/255, blue: 186/255, alpha: 1)
                        button.layer.cornerRadius = 25
                        button.addTarget(self, action: #selector(self?.unlockClicked), for: .touchUpInside)
                        
                        self?.privacyWindow?.addSubview(button)
                        
                        button.translatesAutoresizingMaskIntoConstraints = false
                        button.widthAnchor.constraint(equalToConstant: 200).isActive = true
                        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
                        
                        button.centerXAnchor.constraint(equalTo: self!.privacyWindow.centerXAnchor).isActive = true
                        button.centerYAnchor.constraint(equalTo: self!.privacyWindow.centerYAnchor).isActive = true
                        
                        return
                    }
                    
                    //Hide the screen
                    self?.privacyWindow?.isHidden = true
                    self?.privacyWindow = nil
                    self?.initalAuthentation = true
                    self?.needPassword = false
                }
            }
            
        }
        else{
            //Authentication failed
            let alertController = UIAlertController(title: "Unavailable", message: "Cannot use this feature", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    //Helper function that calls the biometric/password authentication again
    @objc func unlockClicked(){
        hidePrivacyScreen()
    }
    
}

