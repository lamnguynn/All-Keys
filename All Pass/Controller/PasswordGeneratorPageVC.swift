//
//  PasswordGeneratorPageVC.swift
//  All Pass
//
//  Created by Lam Nguyen on 6/28/21.
//

import UIKit
import CoreData

class PasswordGeneratorPageVC: UIViewController {

    let headerLabel = UILabel()
    let passwordLabel = UILabel()
    let table = UITableView()
    
    // MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    
        // Load from core data
        let fetchRequest2: NSFetchRequest<PasswordGenSettings> = PasswordGenSettings.fetchRequest()
        do{
            let cmpy =  try PersistenceManager.context.fetch(fetchRequest2)
            password.savedSettings = cmpy
        }catch{
            //Catch error. Later on send an email to developer about any issue
            print("error: failed to load data")
        }
        
        // Set up the header label
        view.addSubview(headerLabel)
        headerLabel.attributedText = NSAttributedString(string: "Options", attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 34),
            NSAttributedString.Key.foregroundColor: UIColor(red: 152, green: 152, blue: 152)
        ])
        headerLabel.adjustsFontSizeToFitWidth = true
        
        addLabelConstraints(headerLabel)
        
        // Set up the table
        view.addSubview(table)
        table.delegate = self
        table.dataSource = self
        table.register(PasswordGenTableCell.self, forCellReuseIdentifier: "datacell")              //Register the cell
        table.isScrollEnabled = false                                                               //Disable scrolling
        table.separatorStyle = .none
        table.allowsSelection = false
        table.layer.cornerRadius = 20
        
        addTableConstraints()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //Build the new entry
        let lower = table.cellForRow(at: IndexPath(row: 0, section: 0)) as! PasswordGenTableCell
        let upper = table.cellForRow(at: IndexPath(row: 1, section: 0)) as! PasswordGenTableCell
        let numbers = table.cellForRow(at: IndexPath(row: 2, section: 0)) as! PasswordGenTableCell
        let specialChar = table.cellForRow(at: IndexPath(row: 3, section: 0)) as! PasswordGenTableCell
        let length = table.cellForRow(at: IndexPath(row: 4, section: 0)) as! PasswordGenTableCell
        
        let newEntry = PasswordGenSettings(context: PersistenceManager.context)
        newEntry.lowerCase = lower.switchToggle.isOn
        newEntry.upperCase = upper.switchToggle.isOn
        newEntry.numbers = numbers.switchToggle.isOn
        newEntry.specialChar = specialChar.switchToggle.isOn
        newEntry.length = length.slider.value

        //Save to core data. Delete previous saved setting
        if !password.savedSettings.isEmpty{
            PersistenceManager.context.delete(password.savedSettings[0])
            password.savedSettings.remove(at: 0)
            password.savedSettings.append(newEntry)
        }
        PersistenceManager.saveContext()
    }
    
    
    // MARK: asset constraints
    
    /*
        @addLabelConstraints
        Adds constraints to a given label argument
        -- label: label to add constraints to
     */
    func addLabelConstraints(_ label: UILabel){
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: self.view.frame.width - 12).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height / 6.49).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14).isActive = true
    }
    
    /*
        @addTableConstraints
        Adds constraints to the table view
     */
    func addTableConstraints(){
        table.translatesAutoresizingMaskIntoConstraints = false
        table.heightAnchor.constraint(equalToConstant: 360).isActive = true
        table.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12).isActive = true
        table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
    }
    
    /*
        @createPassword
        Generate a password from the switches by building a list of available characters and randomly picking them
     */
    func createPassword(lower l: Bool, upper u: Bool, numbers n: Bool, specialChar sC: Bool, length len: Float) -> String{
        //Set up the input data
        var availableChar = [String]()
        var passwordGen = ""
        
        //Add characters based on the switch
        
        if l{   //Lower Case
            for i in 97...122{  availableChar.append(String(Character(UnicodeScalar(i)!)))  }
        }
        if u{   //Upper Case
            for i in 65...90{  availableChar.append(String(Character(UnicodeScalar(i)!)))  }
        }
        if n{   //Numbers
            for i in 48...57{  availableChar.append(String(Character(UnicodeScalar(i)!)))  }
        }
        if sC{  //Special Characters
            for i in 33...38{
                if i == 34{ continue }      //Skip quotation
                availableChar.append(String(Character(UnicodeScalar(i)!)))
            }
            availableChar.append(String(Character(UnicodeScalar(45)!)))
        }
 
        //Generate the password
        for _ in 1...Int16(len){
            passwordGen.append(availableChar.randomElement()!)
        }
        
        return passwordGen
    }
    
}

// MARK: table function
extension PasswordGeneratorPageVC: UITableViewDelegate, UITableViewDataSource{
    
    /*
        @cellForRowAt
        Customizes the cells based on specifications
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Customize the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "datacell", for: indexPath) as! PasswordGenTableCell
        
        //Customize the title label
        cell.titleLabel.textColor = .white
        cell.titleLabel.font = UIFont.systemFont(ofSize: 16)
        cell.sliderValueBackView.isHidden = true
        cell.sliderValueLabel.isHidden = true
        cell.passwordBackView.isHidden = true
        
        if indexPath.row == 0       { cell.titleLabel.text = "Lower Case (a-z)"; cell.slider.isHidden = true; cell.copyButton.isHidden = true;
            cell.switchToggle.addTarget(self, action: #selector(maintainOneSwitchOn(toggle: )), for: .valueChanged) }
        else if indexPath.row == 1  { cell.titleLabel.text = "Upper Case (A-Z)"; cell.slider.isHidden = true; cell.copyButton.isHidden = true;
            cell.switchToggle.addTarget(self, action: #selector(maintainOneSwitchOn(toggle: )), for: .valueChanged) }
        else if indexPath.row == 2  { cell.titleLabel.text = "Numbers (0-9)"; cell.slider.isHidden = true;    cell.copyButton.isHidden = true;
            cell.switchToggle.addTarget(self, action: #selector(maintainOneSwitchOn(toggle: )), for: .valueChanged) }
        else if indexPath.row == 3  { cell.titleLabel.text = "Special Characters (!$%&-)"; cell.slider.isHidden = true;  cell.copyButton.isHidden = true
            cell.switchToggle.addTarget(self, action: #selector(maintainOneSwitchOn(toggle: )), for: .valueChanged)
        }
        else if indexPath.row == 4  {
            cell.titleLabel.text = "Length";
            cell.switchToggle.isHidden = true;
            cell.copyButton.isHidden = true
            cell.slider.addTarget(self, action: #selector(sliderAction), for: .valueChanged)
            cell.sliderValueBackView.isHidden = false
            cell.sliderValueLabel.isHidden = false
            cell.sliderValueLabel.text = (Int16(password.savedSettings[0].length)).description
            
        }
        else if indexPath.row == 5  {
            cell.slider.isHidden = true;
            cell.switchToggle.isHidden = true
            
            //Initialize the variables of the configurations.
            cell.titleLabel.text = createPassword(lower: password.savedSettings[0].lowerCase,
                                                  upper: password.savedSettings[0].upperCase,
                                                  numbers: password.savedSettings[0].numbers,
                                                  specialChar: password.savedSettings[0].specialChar,
                                                  length: password.savedSettings[0].length)
            
            cell.copyButton.addTarget(self, action: #selector(copyClicked), for: .touchUpInside)
            cell.refreshButton.addTarget(self, action: #selector(refreshClicked), for: .touchUpInside)
            cell.passwordBackView.isHidden = false
        }
        
        //Apply saved settings
        if !password.savedSettings.isEmpty{
            if indexPath.row == 0       { cell.switchToggle.isOn = password.savedSettings[0].lowerCase }
            else if indexPath.row == 1  { cell.switchToggle.isOn = password.savedSettings[0].upperCase }
            else if indexPath.row == 2  { cell.switchToggle.isOn = password.savedSettings[0].numbers  }
            else if indexPath.row == 3  { cell.switchToggle.isOn = password.savedSettings[0].specialChar }
            else if indexPath.row == 4  { cell.slider.value = password.savedSettings[0].length }
        }
        
        return cell
    }
    
    /*
        @numberOfRowsInSection
        Returns the number of cells
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    /*
        @heightForRowAt
        Returns the height of a cell
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: objc action functions
    
    @objc func maintainOneSwitchOn(toggle: UISwitch){
        let lower = (table.cellForRow(at: IndexPath(row: 0, section: 0)) as! PasswordGenTableCell).switchToggle.isOn
        let upper = (table.cellForRow(at: IndexPath(row: 1, section: 0)) as! PasswordGenTableCell).switchToggle.isOn
        let numbers = (table.cellForRow(at: IndexPath(row: 2, section: 0)) as! PasswordGenTableCell).switchToggle.isOn
        let specialChar = (table.cellForRow(at: IndexPath(row: 3, section: 0)) as! PasswordGenTableCell).switchToggle.isOn
        
        //Use a nor statement to check if all toggles are off. If so, keep the most recently turned off one back on and alert to user
        if !(lower || upper || numbers || specialChar){
            let alert = UIAlertController(title: "Warning:", message: "At least one option must be selected", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            toggle.setOn(true, animated: true)
        }
    }
    
    /*
        @sliderAction
        Generates a password given what the slider value is and the other switches
     */
    @objc func sliderAction(){
        //Initialize variables for each toggle/slider
        let lower = table.cellForRow(at: IndexPath(row: 0, section: 0)) as! PasswordGenTableCell
        let upper = table.cellForRow(at: IndexPath(row: 1, section: 0)) as! PasswordGenTableCell
        let numbers = table.cellForRow(at: IndexPath(row: 2, section: 0)) as! PasswordGenTableCell
        let specialChar = table.cellForRow(at: IndexPath(row: 3, section: 0)) as! PasswordGenTableCell
        let length = table.cellForRow(at: IndexPath(row: 4, section: 0)) as! PasswordGenTableCell
        let passwordCell = table.cellForRow(at: IndexPath(row: 5, section: 0)) as! PasswordGenTableCell
        
        //Create the password given some arguments
        passwordCell.titleLabel.text = createPassword(lower: lower.switchToggle.isOn,
                                                      upper: upper.switchToggle.isOn,
                                                      numbers: numbers.switchToggle.isOn,
                                                      specialChar: specialChar.switchToggle.isOn,
                                                      length: length.slider.value)
        //Update the value of the slider
        let sliderValueLabel = (table.cellForRow(at: IndexPath(row: 4, section: 0)) as! PasswordGenTableCell).sliderValueLabel
        sliderValueLabel.text = (Int16(length.slider.value)).description
    }
    
    /*
        @copyClicked
        Copies the password text when clicked. Shows an alert to inform user
     */
    @objc func copyClicked(){
        //Only allow copying if there is text
        let passwordCell = table.cellForRow(at: IndexPath(row: 5, section: 0)) as! PasswordGenTableCell
        let passwordGenerated = passwordCell.titleLabel.text
        guard passwordGenerated != nil else{
            return
        }
        
        //Show an alert for 1 seconds
        let alertController = UIAlertController(title: "Copied!", message: nil, preferredStyle: .alert)
        self.present(alertController, animated: true)
        
        //Using GCD as my timer. Quite overkill as nothing is happening on the main thread.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.86) {
            self.dismiss(animated: true, completion: nil)
        }

        //Copy to clipboard
        UIPasteboard.general.string = passwordGenerated
    }
    
    /*
        @refreshClicked
        Refreshes the password label to a new password
     */
    @objc func refreshClicked(){
        let passwordCell = table.cellForRow(at: IndexPath(row: 5, section: 0)) as! PasswordGenTableCell
        
        //Initialize variables for each toggle/slider
        let lower = table.cellForRow(at: IndexPath(row: 0, section: 0)) as! PasswordGenTableCell
        let upper = table.cellForRow(at: IndexPath(row: 1, section: 0)) as! PasswordGenTableCell
        let numbers = table.cellForRow(at: IndexPath(row: 2, section: 0)) as! PasswordGenTableCell
        let specialChar = table.cellForRow(at: IndexPath(row: 3, section: 0)) as! PasswordGenTableCell
        let length = table.cellForRow(at: IndexPath(row: 4, section: 0)) as! PasswordGenTableCell
        
        passwordCell.titleLabel.text = createPassword(lower: lower.switchToggle.isOn,
                                                     upper: upper.switchToggle.isOn,
                                                     numbers: numbers.switchToggle.isOn,
                                                     specialChar: specialChar.switchToggle.isOn,
                                                     length: length.slider.value)
    }
}
