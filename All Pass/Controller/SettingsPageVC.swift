//
//  SettingsPageVC.swift
//  All Pass
//
//  Created by Lam Nguyen on 6/19/21.
// 

import UIKit
import MessageUI
import LocalAuthentication

class SettingsPageVC: UIViewController {

    let supportTable    = UITableView()                 //Table to show support options
    let supportLabel    = UILabel()                     //Label on top of the support table
    let configTable     = UITableView()                 //Table to show configuration options
    let configLabel     = UILabel()                     //Label on top of the configuration table
    let appVersion      = "1.1"                         //Value for the app version
    var biometricType: String = ""
    
    // MARK: view life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Set up the supprt table
        view.addSubview(supportTable)
        supportTable.delegate = self
        supportTable.backgroundColor = view.backgroundColor
        supportTable.separatorStyle = .none
        supportTable.isScrollEnabled = false
        supportTable.dataSource = self
        supportTable.register(SettingsTableCell.self, forCellReuseIdentifier: "datacell")
        
        addTableConstraints(supportTable, view.topAnchor, view.frame.height / 6.49 + 20)
        
        // Set up the support label
        view.addSubview(supportLabel)
        supportLabel.attributedText = NSAttributedString(string: "Support", attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor(red: 152, green: 152, blue: 152)
        ])
        supportLabel.adjustsFontSizeToFitWidth = true
        
        addLabelConstraints(supportLabel, supportTable.topAnchor)
        
        // Set up the configuation table
        view.addSubview(configTable)
        configTable.delegate = self
        configTable.backgroundColor = view.backgroundColor
        configTable.separatorStyle = .none
        configTable.isScrollEnabled = false
        configTable.dataSource = self
        configTable.register(SettingsTableCell.self, forCellReuseIdentifier: "datacell2")

        addTableConstraints(configTable, supportTable.bottomAnchor, 65)
        
        // Set up the configuration label
        view.addSubview(configLabel)
        configLabel.attributedText = NSAttributedString(string: "Configuration", attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor(red: 152, green: 152, blue: 152)
        ])
        configLabel.adjustsFontSizeToFitWidth = true
        
        addLabelConstraints(configLabel, configTable.topAnchor)
        
        //Add an observer to refresh the data when scene is active again
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    // MARK: asset constraints
    
    /*
        @addTableConstraints
        Adds constraints to a table based on the given arguments
        -- table:       table to add constraints to
        -- topAnchor:   top anchor of the table
        -- topPadding:  constant to add padding for the topAnchor
     */
    func addTableConstraints(_ table: UITableView, _ topAnchor: NSLayoutYAxisAnchor, _ topPadding: CGFloat = 0){
        table.translatesAutoresizingMaskIntoConstraints = false
        table.heightAnchor.constraint(equalToConstant: 200).isActive = true
        table.topAnchor.constraint(equalTo: topAnchor, constant: topPadding).isActive = true
        table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18).isActive = true
    }
    
    /*
        @addLabelConstraints()
        Adds constraints to a label based on the given arguments
        -- label:           label to add constraints to
        -- bottomAnchor:    bottom anchor of the table
     */
    func addLabelConstraints(_ label: UILabel, _ bottomAnchor: NSLayoutYAxisAnchor){
        label.translatesAutoresizingMaskIntoConstraints = false
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22).isActive = true
    }
    
    // MARK: quality of life functions
    
    /*
        @findNextFourFactor
        Takes a value and finds the next whole number that is divisible by four (number of cells in the table)
        -- val: value to start evaluating from
     */
    func findNextFourFactor(_ val: CGFloat) -> CGFloat{
        //Round the passed in value up
        var num = round(val)
        
        //Loop until the value is divisible by four. Theoretically runs in O(N) but realistically runs in O(4) at worst
        while num.remainder(dividingBy: 4) != 0 {
            num += 1
        }
        
        return num
    }
}

// MARK: table functions
extension SettingsPageVC: UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == supportTable{
            // Set up the cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "datacell") as! SettingsTableCell
            cell.selectionStyle = .none
            cell.backgroundColor = .white
            
            // Set up the title label
            cell.titleLabel.textColor = .black
            cell.titleLabel.font = UIFont.systemFont(ofSize: 20)
            if indexPath.row == 0       { cell.titleLabel.text = "Report Bugs"; cell.continueButton.addTarget(self, action: #selector(reportBugsClicked), for: .touchUpInside) }
            else if indexPath.row == 1  { cell.titleLabel.text = "Contact"; cell.continueButton.addTarget(self, action: #selector(contactClicked), for: .touchUpInside) }
            else if indexPath.row == 2  { cell.titleLabel.text = "Privacy Policy"; cell.continueButton.addTarget(self, action: #selector(privacyClicked), for: .touchUpInside) }
            else if indexPath.row == 3  { cell.titleLabel.text = "App Version" }
            
            // Set up the button
            cell.continueButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            cell.continueButton.tintColor = .gray
            cell.continueButton.contentHorizontalAlignment = .right
            if indexPath.row == 3{
                cell.continueButton.setImage(nil, for: .normal)
                cell.continueButton.isUserInteractionEnabled = false
                cell.continueButton.setTitle(appVersion, for: .normal)
                cell.continueButton.setTitleColor(.gray, for: .normal)
            }
            
            //Hide the switch
            cell.switchToggle.isHidden = true
            
            return cell
        }
        else if tableView == configTable{
            //Set up the cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "datacell2") as! SettingsTableCell
            cell.selectionStyle = .none
            cell.backgroundColor = .white
            
            // Set up the title label
            cell.titleLabel.textColor = .black
            cell.titleLabel.font = UIFont.systemFont(ofSize: 20)
            if indexPath.row == 0       {                                                                                   //Password Generator
                cell.titleLabel.text = "Password Generator";
                cell.continueButton.addTarget(self, action: #selector(passGenClicked), for: .touchUpInside)
                cell.switchToggle.isHidden = true
            }
            else if indexPath.row == 1  {
                cell.titleLabel.text = "Autofill"
                cell.continueButton.isHidden = false
                cell.switchToggle.isHidden = true
                cell.continueButton.addTarget(self, action: #selector(autofillClicked), for: .touchUpInside)
            }
            else if indexPath.row == 2  {                                                                                   //Notifications
                cell.titleLabel.text = "Notifications"
                cell.continueButton.isHidden = true
                cell.switchToggle.isHidden = false
                configureSwitch(cell.switchToggle)
                cell.switchToggle.addTarget(self, action: #selector(switchNotifications(switchT: )), for: .valueChanged)
            }
            else if indexPath.row == 3  {                                                                                   //FaceID
                let context = LAContext()
                
                if #available(iOS 11, *) {
                    switch(context.biometryType){
                    case .none:
                        cell.titleLabel.isHidden = true
                        cell.continueButton.isHidden = true
                        cell.switchToggle.isHidden = true
                        return cell
                    case .faceID:
                        cell.titleLabel.text = "Face ID"
                        biometricType = "Face ID"
                        break
                    case .touchID:
                        cell.titleLabel.text = "Touch ID"
                        break
                    @unknown default:
                        print("unknown")
                    }
                }
                cell.continueButton.isHidden = true
                cell.switchToggle.isHidden = false
                configureBiometricSwitch(cell.switchToggle)
                cell.switchToggle.addTarget(self, action: #selector(switchBiometric(switchT: )), for: .valueChanged)
            }
            /*
            else if indexPath.row == 3  { cell.titleLabel.text = "Autofill Credentials" }
            */
            
            // Set up the button
            cell.continueButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            cell.continueButton.tintColor = .gray
            cell.continueButton.contentHorizontalAlignment = .right
            
            
            // Set up the FaceID toggle switch
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    /*
        @configureSwitch
        Toggles the switch depending on settings
     */
    private func configureSwitch(_ switchToggle: UISwitch){
        //Check the settings to determine if the switch should be on/off
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            //If notifications is authorized, then toggle on
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    switchToggle.setOn(true, animated: true)
                }
                return
            }
            else{
                //Either denied or undetermined
                DispatchQueue.main.async {
                    switchToggle.setOn(false, animated: true)
                }
            }
        }
    }
    
    /*
        @configureFaceIDSwitch
        Toggles the switch based on face id biometry types
     */
    private func configureBiometricSwitch(_ switchToggle: UISwitch){
        let biometricEnabled = (LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil))
        if biometricEnabled {
            //Toggle on
            switchToggle.setOn(true, animated: true)
        }
        else{
            //Toggle off
            switchToggle.setOn(false, animated: true)
        }
    }
    
    /*
        @numberOfRowsInSection
        Returns the number of cells in the table
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == supportTable{
            return 4
        }
        else{
            return 4
        }
    }
    
    /*
        @heightForRowAt
        Returns the height of a cell
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // MARK: objc helper functions
    
    /*
        @handleAppDidBecomeActive
        Refreshes the data on scene when the it is active
     */
    @objc func handleAppDidBecomeActive(){
        //Refreshes the notification switch
        let cells = (configTable.visibleCells)
        let switchTN = (cells[2] as! SettingsTableCell).switchToggle
        configureSwitch(switchTN)
        
       //Refreshes the biometric swift
        let switchTB = (cells[3] as! SettingsTableCell).switchToggle
        configureBiometricSwitch(switchTB)
    }
    
    /*
        @switchBiometric
        Toggles the biometric switch
     */
    @objc func switchBiometric(switchT: UISwitch){
        //Build the controller
        var alertController: UIAlertController!
        if !switchT.isOn{
            //Turn off biometrics by alerting the user they will be redirected to settings
            alertController = UIAlertController(title: "Disable \(biometricType)", message: "Please disable \(biometricType) in settings", preferredStyle: .alert)
        }
        else{
            //Turn on biometrics by alerting the user they will be redirected to settings
            alertController = UIAlertController(title: "Enable \(biometricType)", message: "Please enable \(biometricType) in settings", preferredStyle: .alert)
        }
        
        //Add actions and present the controller
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            //Redirect to settings
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else{
                return
            }
            if UIApplication.shared.canOpenURL(settingsURL){
                UIApplication.shared.open(settingsURL)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            //Toggle the switch back
            DispatchQueue.main.async {
                switchT.setOn(true, animated: true)
            }
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /*
        @switchNotifications
        Toggles the notification switch
     */
    @objc func switchNotifications(switchT: UISwitch){
        //Build the controller
        var alertController: UIAlertController!
        if !switchT.isOn{
            //Turn off notifications by alerting the user they will be redirected to settings
            alertController = UIAlertController(title: "Disable Notifications", message: "Please disable notifications in settings", preferredStyle: .alert)
        }
        else{
            //Turn on notifications by alerting the user they will be redirected to settings
            alertController = UIAlertController(title: "Enable Notifications", message: "Please enable notifications in settings", preferredStyle: .alert)
        }
        
        //Add actions and present the controller
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            //Redirect to settings
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else{
                return
            }
            if UIApplication.shared.canOpenURL(settingsURL){
                UIApplication.shared.open(settingsURL)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            //Toggle the switch back
            DispatchQueue.main.async {
                switchT.setOn(true, animated: true)
            }
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /*
        @reportBugsClicked
        When clicked, open up the link to report bugs form
     */
    @objc func reportBugsClicked(){
        let urlString = "https://docs.google.com/forms/d/e/1FAIpQLSdbu2sGxIGMiXH723VAXdDwZZKpD0p1Wss-YvYX6_mn2l9yBg/viewform"
        if let urlToOpen  = URL(string: urlString){             //Open Report Bugs Link
            UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
        }
    }
    
    /*
        @contactClicked
        When clicked, opens up a view controller to contact developer
     */
    @objc func contactClicked(){
        //Check to see if Mail is setup on device
        guard MFMailComposeViewController.canSendMail() else{
            let alertController = UIAlertController(title: "Error", message: "Please set up mail on device", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
            return
        }
        
        //Open the mail controller
        let mailcntr = MFMailComposeViewController()
        mailcntr.mailComposeDelegate = self
        mailcntr.setSubject("All Keys Contact")                                               //Email Subject
        mailcntr.setToRecipients(["lance66nguyen@gmail.com"])                        //Email Recipients
        
        present(mailcntr, animated: true)
    }
    
    @objc func passGenClicked(){
        let next: PasswordGeneratorPageVC = storyboard?.instantiateViewController(identifier: "passwordGeneratorPageVC") as! PasswordGeneratorPageVC
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    @objc func autofillClicked(){
        let next = AutofillInstructionsPageVC()
        next.modalPresentationStyle = .overCurrentContext
        self.present(next, animated: false)
    }
    
    /*
        @didFinishWith
        Dismiss the mail view controller when cancel is clicked or mail is sent
     */
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func privacyClicked(){
        let urlString = "https://lamnguynn.github.io/All-Keys/"
        if let urlToOpen  = URL(string: urlString){             //Open Privacy Policy Link
            UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
        }
    }
}
