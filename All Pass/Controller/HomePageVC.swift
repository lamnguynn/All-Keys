//
//  HomePageVC.swift
//  All Pass
//
//  Created by Lam Nguyen on 6/18/21.
//

import UIKit
import CoreData
import SwiftKeychainWrapper

//struct to make a global array of company names and usernames
public struct companyNames{
    public static var container: [UserKey] = [UserKey]()                //Container to hold the company names and usernames
}

struct password{                                                        //Container to hold the password generator settings
    public static var savedSettings = [PasswordGenSettings]()
}

//MARK: main functions for the view controller and navigation bar
class HomePageVC: UIViewController, UISearchBarDelegate, copyPasswordDelegate {

    lazy var nothinglabel = UILabel()                           //Label to display when no credentials have been added
    lazy var keychainImageView = UIImageView()                  //View to hold an image of a keychain
    var filteredCompany = [UserKey]()                           //Container to hold the filtered companies
    var filtered = false                                        //Variable to hold if the table has been filtered.
    var searchBarEditing = false                                //Condition if the search bar is active
    var homeBackgroundColor: UIColor = .white                   //Color for the scenes background
    let refreshControl = UIRefreshControl()
    @IBOutlet var table: UITableView!                           //Table to display all the passwords
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = homeBackgroundColor
        
        //Set up the table
        table?.delegate = self
        table?.dataSource = self
        table?.separatorStyle = .none
        table.backgroundColor = homeBackgroundColor
        table.keyboardDismissMode = .onDrag
        
        //Set up refresh
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.tintColor = UIColor.myGray()
        table.addSubview(refreshControl)
        
        //Set up the search bar
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        
        //Set up the navigation
        configureItems()
        navigationController?.navigationBar.barTintColor = UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1)
        
        //Load all the data for company names
        let fetchRequest: NSFetchRequest<UserKey> = UserKey.fetchRequest()
        do{
            let cmpy =  try PersistenceManager.context.fetch(fetchRequest)
            companyNames.container = cmpy
        }catch{
            //Catch error. Later on send an email to developer about any issue
            print("error: failed to load data")
        }
        
        //Set up the empty message
        configureEmptyItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //If the home screen is empty, show a picture and message in the middle
        if companyNames.container.isEmpty{
            showEmptyHomeItems()
        }
        else{
            hideEmptyHomeItems()
        }
        
        DispatchQueue.main.async {
            self.table.reloadData()
        }
        
        //Load all the data for the password generator settings
        let fetchRequest2: NSFetchRequest<PasswordGenSettings> = PasswordGenSettings.fetchRequest()
        do{
            let cmpy =  try PersistenceManager.context.fetch(fetchRequest2)
            password.savedSettings = cmpy
            //If the settings is empty, provide some dummy info
            if password.savedSettings.isEmpty{
                let newEntry = PasswordGenSettings(context: PersistenceManager.context)
                newEntry.lowerCase = true
                newEntry.upperCase = true
                newEntry.numbers = true
                newEntry.specialChar = true
                newEntry.length = 10
                password.savedSettings.append(newEntry)
            }
        }catch{
            //Catch error. Later on send an email to developer about any issue
            print("error: failed to load data")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    // MARK: search bar functions

    /*
     Providws the text from the search bar in real time
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Remove any pre-existing data in the filtered container
        filteredCompany.removeAll()
        
        //Filter the company name container
        for cmp in companyNames.container{
            if let cmpName = cmp.name{
                if cmpName.lowercased().starts(with: searchText.lowercased()) && searchText != ""{
                    filteredCompany.append(cmp)
                }
            }
        }
        
        //Reload the table
        DispatchQueue.main.async {
            self.table?.reloadData()
        }
        
        filtered = searchText == "" ? false : true                 //Data has been filtered
    }
    
    /*
     Dismiss keyboard when search is pressed
     */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBarEditing = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBarEditing = false
    }
    
    // MARK: asset supporting functions
    
    /*
     Copy the password to the clipboard by getting the key.
     */
    func copyPass(cell: HomePageTableCell) {
        //Show an alert for 1 seconds
        let alertController = UIAlertController(title: "Copied!", message: nil, preferredStyle: .alert)
        self.present(alertController, animated: true)
        
        //Using GCD as my timer. Quite overkill as nothing is happening on the main thread.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.86) {
            self.dismiss(animated: true, completion: nil)
        }

        //Copy to clipboard
        let companyName = cell.nameLabel.text!
        var userName: String?
        if filteredCompany.count != 0{
            userName = filteredCompany[(table?.indexPath(for: cell)!.row)!].username
        }
        else{
            userName = companyNames.container[(table?.indexPath(for: cell)!.row)!].username!
        }
        let key = companyName + "_" + userName!
        UIPasteboard.general.string = KeychainWrapper.standard.string(forKey: key)
    }
    
    /*
     Add any navigation items
     */
    private func configureItems(){
        //Create right bar items
        let plusImage = UIImage(systemName: "plus")
        let gearImage = UIImage(systemName: "gear")
        let bellImage = UIImage(systemName: "bell")
        
        let plusItem = UIBarButtonItem(image: plusImage, style: .plain, target: self, action: #selector(showNewPasswordVC))
        let gearItem = UIBarButtonItem(image: gearImage, style: .plain, target: self, action: #selector(showSettingsVC))
        let bellItem = UIBarButtonItem(image: bellImage, style: .plain, target: self, action: #selector(showNotificationVC))
        
        //Customize the items
        plusItem.tintColor = .white
        gearItem.tintColor = .white
        bellItem.tintColor = .white
        
        //Add the items to the navigation
        navigationItem.rightBarButtonItems = [plusItem, gearItem]
        navigationItem.leftBarButtonItem = bellItem
    }
    
    /*
     Create the empty home items to show if the home page is empty
     */
    private func configureEmptyItems(){
        //Create the label and image
        nothinglabel.text = "Nothing here yet..."
        nothinglabel.textColor = .gray
        nothinglabel.adjustsFontSizeToFitWidth = true
        nothinglabel.minimumScaleFactor = 0.5
        
        let image = UIImage(named: "keychain")
        keychainImageView = UIImageView(image: image)
        
        //Add to view and apply constraints (could use a stackview)
        table.addSubview(keychainImageView)
        table.addSubview(nothinglabel)
        
        keychainImageView.translatesAutoresizingMaskIntoConstraints = false
        keychainImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        keychainImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        keychainImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        keychainImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        keychainImageView.alpha = 0.3
        
        nothinglabel.translatesAutoresizingMaskIntoConstraints = false
        nothinglabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        nothinglabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        nothinglabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        nothinglabel.topAnchor.constraint(equalTo: keychainImageView.topAnchor, constant: 100).isActive = true
        nothinglabel.alpha = 0.3
    }
    
    /*
     Hide the empty home items
     */
    func showEmptyHomeItems(){
        nothinglabel.isHidden = false
        keychainImageView.isHidden = false
    }
    
    /*
     Show the empty home items
     */
    func hideEmptyHomeItems(){
        nothinglabel.isHidden = true
        keychainImageView.isHidden = true
    }
    
    
    //MARK: objc helper functions
    
    @objc func showNewPasswordVC(){
        let vc = NewCredentialPage()
        vc.modalPresentationStyle = .overCurrentContext
        vc.homePage = self
        
        self.view.endEditing(true)
        self.present(vc, animated: false)
         
    }
    
    @objc func showSettingsVC(){
        let next: SettingsPageVC = storyboard?.instantiateViewController(identifier: "settingsPageVC") as! SettingsPageVC
        self.view.endEditing(true)
        
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    
    @objc func showNotificationVC(){
        let next: ReminderCenterPageVC = storyboard?.instantiateViewController(identifier: "notificationCenterPageVC") as! ReminderCenterPageVC
        self.view.endEditing(true)
        
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    @objc func refresh(){
        //Reload the table and move the top constraints of the table down
        DispatchQueue.main.async {
            self.table.reloadData()
        }
        
        //Add a end condition for the table refresh; If the number of rows is equal to the number of entries, stop refreshing.
        if table.numberOfRows(inSection: 0) == companyNames.container.count || table.numberOfRows(inSection: 0) == filteredCompany.count{
            refreshControl.endRefreshing()
        }
    }
    
    func showInfoVC(_ indexPath: IndexPath){
        let next: ViewInfoPageVC = storyboard?.instantiateViewController(identifier: "viewInfoPageVC") as! ViewInfoPageVC
        
        //Pass the credentials to the next scene
        if filteredCompany.count != 0{
            next.credentialDetails = filteredCompany[indexPath.row]
        }
        else{
            next.credentialDetails = companyNames.container[indexPath.row]
        }
        next.indexPath = indexPath.row
        
        // Push the scene and end editing
        self.view.endEditing(true)
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
     
}

//MARK: main functions for the table
extension HomePageVC: UITableViewDelegate, UITableViewDataSource{
    //MARK: technical changes to table
    
    //Return the number of rows/cells there are
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredCompany.count != 0{
            return filteredCompany.count
        }
        
        //If the data has been filtered and the filteredCompany container is empty, we should display nothing. Else display the companyNames
        return filtered ? 0 : companyNames.container.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Create the cell and apply some changes to appearance
        let cell = tableView.dequeueReusableCell(withIdentifier: "datacell", for: indexPath) as! HomePageTableCell
        cell.delegate = self
        cell.layer.cornerRadius = 20
        cell.backgroundColor = homeBackgroundColor
        cell.selectionStyle = .none
        
        let selectView = UIView()
        selectView.backgroundColor = UIColor(red: 209/255, green: 209/255, blue: 209/255, alpha: 1)
        cell.selectedBackgroundView = selectView
         
        //Customize the backview of the cell
        cell.cellBackView.backgroundColor = homeBackgroundColor
        cell.cellBackView.layer.cornerRadius = 15
        cell.cellBackView.layer.shadowColor = homeBackgroundColor == .white ? UIColor(red: 218, green: 218, blue: 218).cgColor : UIColor.darkGray.cgColor
        cell.cellBackView.layer.shadowRadius = 5
        cell.cellBackView.layer.shadowOffset = .zero
        cell.cellBackView.layer.shadowOpacity = 0.6
        
        //Customize the company icon image
        cell.companyBackView.backgroundColor = UIColor(red: 70/255, green: 172/255, blue: 183/255, alpha: 1)
        cell.companyBackView.layer.cornerRadius = 24
        cell.companyInterBackView.backgroundColor = homeBackgroundColor
        cell.companyInterBackView.layer.cornerRadius = 20
        cell.companyInitialLabel.textColor = UIColor(red: 70/255, green: 172/255, blue: 183/255, alpha: 1)
        
        //Customize the text labels of the cell
        let image: UIImage? = UIImage(systemName: "doc.on.doc.fill")
        cell.copyButton.setImage(image, for: .normal)
        cell.copyButton.setTitle(nil, for: .normal)
        cell.copyButton.tintColor = UIColor(red: 70/255, green: 172/255, blue: 183/255, alpha: 1)
        cell.nameLabel.textColor = homeBackgroundColor == .white ? .black : .white
        cell.nameLabel.font = UIFont(name: "NotoSans-Regular", size: 16)
        
        let attributes = [
            NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 11),
            NSAttributedString.Key.foregroundColor: UIColor.gray
        ]
        
        //Choose what data to display based on if there is filtered data
        if filteredCompany.count != 0{
            if let text = filteredCompany[indexPath.row].name{
                cell.nameLabel.text = text
                var initialText = String(text[(text.index(text.startIndex, offsetBy: 0))]).uppercased()
                if  text.count > 1{
                    initialText += String(text[(text.index(text.startIndex, offsetBy: 1))]).lowercased()
                }
                cell.companyInitialLabel.text = initialText
                cell.usernameLabel.attributedText = NSAttributedString(string: filteredCompany[indexPath.row].username!, attributes: attributes)
            }
        }
        else{
            if let text = companyNames.container[indexPath.row].name{
                cell.nameLabel.text = companyNames.container[indexPath.row].name
                var initialText = String(text[(text.index(text.startIndex, offsetBy: 0))]).uppercased()
                if text.count > 1{
                    initialText += String(text[(text.index(text.startIndex, offsetBy: 1))]).lowercased()
                }
                cell.companyInitialLabel.text = initialText
                cell.usernameLabel.attributedText = NSAttributedString(string: companyNames.container[indexPath.row].username!, attributes: attributes)
            }
        }
        return cell
    }
    
    //Add delete and edit features to swiping
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //If the search bar is editing or has content in it, disable swipe action
        guard !searchBarEditing else{
            return UISwipeActionsConfiguration()
        }
        guard searchBar.text == "" else{
            return UISwipeActionsConfiguration()
        }
        
        //Build the action
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { action, view, completion in
            
            //Prompt user using alert to verify deletion
            let confirmAlert = UIAlertController(title: "Confirm", message: "Press confirm to delete password.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { action in
                //Delete from model
                let cmpyObj = companyNames.container[indexPath.row]                                                                 //Core Dara deletion
                PersistenceManager.context.delete(cmpyObj)
                
                let key = companyNames.container[indexPath.row].name! + "_" + companyNames.container[indexPath.row].username!       //Keychain deletion
                KeychainWrapper.standard.removeObject(forKey: key)
                
                companyNames.container.remove(at: indexPath.row)
                
                //Delete from view
                DispatchQueue.main.async {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                PersistenceManager.saveContext()
                
                //If no passwords are left show the empty home items
                DispatchQueue.main.async {
                    if companyNames.container.isEmpty{
                        self.showEmptyHomeItems()
                    }
                }
                
            }
            
            confirmAlert.addAction(cancelAction)
            confirmAlert.addAction(confirmAction)
            
            self.present(confirmAlert, animated: true, completion: nil)
            
            completion(true)
        }
        
        //Customize the actions
        deleteAction.image = UIImage(systemName: "trash")
        
        //Return the actions
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }
    
    //MARK: cosmetic changes to table
    
    //Set the height of the cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    //Deselect the cell when clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        showInfoVC(indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.49, delay: 0.05, animations: {
            cell.alpha = 1
        })
    }
    
    
    func setLogoImage(from url: String, to imageView: UIImageView) {
        guard let imageURL = URL(string: url) else { return }

            // just not to cause a deadlock in UI!
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else { return }

            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                imageView.image = image
            }
        }
    }
}

