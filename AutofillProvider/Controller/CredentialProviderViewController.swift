//
//  CredentialProviderViewController.swift
//  CredentialProvider
//
//  Created by Lam Nguyen on 6/28/21.
//

import AuthenticationServices
import SwiftKeychainWrapper
import CoreData
import LocalAuthentication

class CredentialProviderViewController: ASCredentialProviderViewController, UISearchBarDelegate {
    
    @IBOutlet weak var table: UITableView?                      //Table view to present the credentials
    @IBOutlet weak var searchBar: UISearchBar!                  //Search bar to find a credential
    @IBOutlet weak var categoryCollection: UICollectionView?    //Collection view to show the categories
    var sharedUserContainer = [UserKey]()                       //Container to hold the credentials
    
    var searchFilterUser = [UserKey]()                          //Container to hold the filtered users based on search
    var categoryFilteredUser = [UserKey]()                      //Container to hold the filtered users based on category
    var categorySelected = [String]()                           //Container to hold the categories selected
    var filtered = false
    let categories = ["Education", "Shopping", "Dining", "Social Media", "Personal Finance", "Productivity", "Other"]
    
    // MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.view.endEditing(true)
        
        // Load the username data from core data
        let fetchReq: NSFetchRequest<UserKey> = UserKey.fetchRequest()
        do{
            let cmpy =  try PersistenceManager.context.fetch(fetchReq)
            sharedUserContainer = cmpy
        }catch{
            print("error: failed to load data")
        }
        
        // Set up the navigation bar
        navigationController?.navigationBar.tintColor = UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1)
        
        // Set up the table
        table?.delegate = self
        table?.dataSource = self
        table?.backgroundColor = .white
        table?.separatorStyle = .none
        
        // Set up the collection view
        categoryCollection?.delegate = self
        categoryCollection?.dataSource = self
        categoryCollection?.backgroundColor = .white
        
        // Set up the search bar
        searchBar.barTintColor = .white
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.textColor = .gray
        searchBar.backgroundColor = UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 0.73)
        
        // Set up swipe down gesture
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler(_:)))
        self.view.addGestureRecognizer(gestureRecognizer)
    }
    
    /*
     Prepare your UI to list available credentials for the user to choose from. The items in
     'serviceIdentifiers' describe the service the user is logging in to, so your extension can
     prioritize the most relevant credentials in the list.
    */
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        
    }

    /*
     Implement this method if your extension supports showing credentials in the QuickType bar.
     When the user selects a credential from your app, this method will be called with the
     ASPasswordCredentialIdentity your app has previously saved to the ASCredentialIdentityStore.
     Provide the password by completing the extension request with the associated ASPasswordCredential.
     If using the credential would require showing custom UI for authenticating the user, cancel
     the request with error code ASExtensionError.userInteractionRequired.

    override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
        let databaseIsUnlocked = true
        if (databaseIsUnlocked) {
            let passwordCredential = ASPasswordCredential(user: "j_appleseed", password: "apple1234")
            self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
        } else {
            self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code:ASExtensionError.userInteractionRequired.rawValue))
        }
    }
    */

    /*
     Implement this method if provideCredentialWithoutUserInteraction(for:) can fail with
     ASExtensionError.userInteractionRequired. In this case, the system may present your extension's
     UI and call this method. Show appropriate UI for authenticating the user then provide the password
     by completing the extension request with the associated ASPasswordCredential.

    override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
    }
    */
    
    // MARK: search bar functions
    
    /*
        @searchBarSearchButtonClicked
        Dismiss keyboard when search is pressed
     */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Only dismiss if there is text
        if searchBar.text != ""{
            self.searchBar.endEditing(true)
        }
    }
    
    /*
        @textDidChange
        Provides the text from the search bar in real time
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Remove any pre-existing data in the filtered container
        searchFilterUser.removeAll()
        
        //Filter the company name container
        let containerToUse = (categoryFilteredUser.count != 0) ? categoryFilteredUser : sharedUserContainer
        for cmp in containerToUse{
            if let cmpName = cmp.name{
                if cmpName.lowercased().starts(with: searchText.lowercased()) && searchText != ""{
                    searchFilterUser.append(cmp)
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
        @searchBarTextDidBeginEditing
        Hides the navigation bar and expands the view using an animation
     */
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //Hide the navigation bar
        self.navigationController?.navigationBar.isHidden = true
        var frm = self.view.frame
        frm.origin.y = -44
        frm.size.height += 44
        UIView.animate(withDuration: 0.35) {
            self.view.frame = frm
        }
        
        self.searchBar.showsCancelButton = true
        self.searchBar.tintColor = .white
    }
    
    /*
        @searchBarCancelButtonClicked
        Shows the navigation bar and shrinks the view using an animation
     */
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //Hide the cancel button
        self.searchBar.setShowsCancelButton(false, animated: true)
        
        //Show the navigation bar
        self.navigationController?.navigationBar.isHidden = false
        var frm = self.view.frame
        frm.origin.y = 0
        frm.size.height -= 44
        
        UIView.animate(withDuration: 0.35) {
            self.view.frame = frm
            self.searchBar.endEditing(true)
        }
    }
    
    
    // MARK: IBaction and objc functions
    
    /*
        @panGestureRecognizerHandler
        Handles the gesture action from the user. Either dismiss the view or returning it back to default.
     */
    @objc func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer){
        let touchPoint = sender.location(in: view?.window)
            var initialTouchPoint = CGPoint.zero

            switch sender.state {
                case .began:
                    initialTouchPoint = touchPoint
                case .changed:
                    if touchPoint.y > initialTouchPoint.y {
                        view.frame.origin.y = touchPoint.y - initialTouchPoint.y
                    }
                case .ended, .cancelled:
                    if touchPoint.y - initialTouchPoint.y > 200 {
                        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
                    } else {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.view.frame = CGRect(x: 0,
                                                     y: 0,
                                                     width: self.view.frame.size.width,
                                                     height: self.view.frame.size.height)
                        })
                    }
                case .failed, .possible:
                    break
            @unknown default:
                fatalError()
            }
    }
    
    /*
        @cancel
        Dismisses the extension when clicked
     */
    @IBAction func cancel(_ sender: AnyObject?) {
        self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
    }
}

// MARK: table functions
extension CredentialProviderViewController: UITableViewDelegate, UITableViewDataSource{
    
    /*
        @numberOfRowsInSection
        Returns the number of cell
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchFilterUser.count != 0{
            return searchFilterUser.count
        }
        else if categoryFilteredUser.count != 0{
            return categoryFilteredUser.count
        }
        else if categoryFilteredUser.count == 0 && categorySelected.count != 0{
            return 0
        }
        
        //If the data has been filtered and the filteredCompany container is empty, we should display nothing. Else display the companyNames
        return filtered ? 0 : sharedUserContainer.count
    }
    
    /*
        @cellForRowAt
        Builds a cell to display
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Customize the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "datacell", for: indexPath) as! CredentialProviderTableCell
        cell.backgroundColor = .white
        cell.selectionStyle = .none
        
        //Customize the initials icon
        cell.companyBackView?.layer.cornerRadius = 22
        cell.companyBackView?.backgroundColor =  UIColor(red: 70/255, green: 172/255, blue: 183/255, alpha: 1)
        cell.companyInnerBackView?.layer.cornerRadius = 20
        cell.companyInnerBackView?.backgroundColor = .white
        cell.companyInitialsLabel?.textColor = UIColor(red: 70/255, green: 172/255, blue: 183/255, alpha: 1)
        
        //Choose what data to display based on if there is filtered data
        cell.nameLabel?.textColor = .black
        let attributes = [
            NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 11),
            NSAttributedString.Key.foregroundColor: UIColor.gray
        ]
        
        if searchFilterUser.count != 0{
            if let text = searchFilterUser[indexPath.row].name{
                cell.nameLabel?.text = text
                cell.emailLabel?.attributedText = NSAttributedString(string: searchFilterUser[indexPath.row].username!, attributes: attributes)
                var initialText = String(text[(text.index(text.startIndex, offsetBy: 0))])
                if  text.count > 1{
                    initialText += String(text[(text.index(text.startIndex, offsetBy: 1))]).lowercased()
                }
                cell.companyInitialsLabel?.text = initialText
            }
        }
        else if categoryFilteredUser.count != 0{
            if let text = categoryFilteredUser[indexPath.row].name{
                cell.nameLabel?.text = text
                cell.emailLabel?.attributedText = NSAttributedString(string: categoryFilteredUser[indexPath.row].username!, attributes: attributes)
                var initialText = String(text[(text.index(text.startIndex, offsetBy: 0))])
                if  text.count > 1{
                    initialText += String(text[(text.index(text.startIndex, offsetBy: 1))]).lowercased()
                }
                cell.companyInitialsLabel?.text = initialText
            }
        }
        else if categoryFilteredUser.count == 0 && categorySelected.count != 0{}
        else{
            if let text = sharedUserContainer[indexPath.row].name{
                cell.nameLabel?.text = text
                cell.emailLabel?.attributedText = NSAttributedString(string: sharedUserContainer[indexPath.row].username!, attributes: attributes)
                var initialText = String(text[(text.index(text.startIndex, offsetBy: 0))])
                if  text.count > 1{
                    initialText += String(text[(text.index(text.startIndex, offsetBy: 1))]).lowercased()
                }
                cell.companyInitialsLabel?.text = initialText
            }
        }
    
        
        //Customize the back view
        cell.backView?.backgroundColor = .white
        cell.backView?.layer.cornerRadius = 15
        cell.backView?.layer.shadowColor = UIColor(red: 218, green: 218, blue: 218).cgColor
        cell.backView?.layer.shadowRadius = 5
        cell.backView?.layer.shadowOffset = .zero
        cell.backView?.layer.shadowOpacity = 0.6
        
        return cell
    }
    
    /*
        @heightForRowAt
        Returns the value for the height of a cell
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    /*
        @didSelectRowAt
        Provide the password credential to autofill when a cell is clicked
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //View update
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Retrieve the password and username from the container
        var user = sharedUserContainer[indexPath.row].username
        var name = sharedUserContainer[indexPath.row].name
        if searchFilterUser.count != 0{
            user = searchFilterUser[indexPath.row].username
            name = searchFilterUser[indexPath.row].name
        }
        else if categoryFilteredUser.count != 0{
            user = categoryFilteredUser[indexPath.row].username
            name = categoryFilteredUser[indexPath.row].name
        }
        
        let serviceName = "Lam.All-Keys"
        let keychain = KeychainWrapper(serviceName: serviceName, accessGroup: "AVSYQW6233.com.Lam.All-Keys")
        let password = keychain.string(forKey: name! + "_" + user!)
        
        //Provide the credentials to autofill to fulfill the request
        let passwordCredential = ASPasswordCredential(user: user!, password: password!)
        self.extensionContext.completeRequest(withSelectedCredential: passwordCredential, completionHandler: nil)
    }
}

// MARK: collection functions

extension CredentialProviderViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "datacell", for: indexPath) as! CategeoryCollectionCell
            
        //Customize the cell
        cell.categoryLabel?.text = categories[indexPath.row]            //CHANGE WHEN MAIN APP IS FINALIZED
        cell.categoryLabel?.textColor = .white
        cell.layer.cornerRadius = 12
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOpacity = 1
        cell.layer.shadowRadius = 1
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        //Retain color and properties from click
        if categorySelected.contains(categories[indexPath.row]){
            cell.backgroundColor = UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1)
            cell.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        }
        else{
            cell.backgroundColor = UIColor(red: 74, green: 181, blue: 193)//UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1)
            cell.transform = .identity
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category: String = categories[indexPath.row]           //Category to sort
        
        //Check to see if category has been already selected
        guard !categorySelected.contains(category) else{
            //If category has already been selected, remove it and deselect it
            deselectCategory(at: indexPath, category: category)
            return;
        }
        
        //Sort the table by category
        for entry in sharedUserContainer{
            if entry.category == category{
                categoryFilteredUser.append(entry)
            }
        }
        
        //Change the view to inform user of filtered
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.17) {
            cell?.backgroundColor = UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1)
            cell?.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        }
        
        //Reload the table and add the category to the ones selected
        DispatchQueue.main.async {
            self.table?.reloadData()
        }
        categorySelected.append(category)
    }
    
    // MARK: collection view helper functions
    
    func deselectCategory(at index: IndexPath, category cat: String ){
        //Remove from model
        var i = 0
        for entry in categorySelected{
            if entry == cat{
                categorySelected.remove(at: i)
                break
            }
            i+=1
        }
        
        
        if !categoryFilteredUser.isEmpty{
            i = 0
            for entry in categoryFilteredUser{
                if entry.category == cat{
                    categoryFilteredUser.remove(at: i)
                    continue
                }
                i += 1
            }
        }
        
        let cell = categoryCollection?.cellForItem(at: index)
        UIView.animate(withDuration: 0.17) {
            cell?.backgroundColor = UIColor(red: 74, green: 181, blue: 193)//UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1)
            cell?.transform = .identity
        }
        
        DispatchQueue.main.async {
            self.table?.reloadData()
        }
    }
    
}
