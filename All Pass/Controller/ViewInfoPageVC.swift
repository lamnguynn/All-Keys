//
//  viewInfoPageVC.swift
//  All Pass
//
//  Created by Lam Nguyen on 6/25/21.
//

import UIKit
import SwiftKeychainWrapper
import LocalAuthentication
import CoreData

struct infoDeleteState{
    static var deleting = false
}

// MARK: viewInfoPageVC
class ViewInfoPageVC: UIViewController, UITextFieldDelegate {

    // MARK: view life cycle
    let table = UITableView()

    let containerView = UIView()
    let deleteButton = UIButton()
    let headerLabel = UILabel()
    let menuButton = UIButton()
    
    var categoryIndex: IndexPath = IndexPath()      //Value for the index of a category
    var indexPath: Int?                             //IndexPath of the cell clicked
    var credentialDetails: UserKey?                 //UserKey entry for the cell clicked
    var heightOfTable: CGFloat! = 0                 //Height of the table
    var editItem: UIBarButtonItem!
    var newCategorySelected: Bool = false
    var collectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Add a edit button to edit credentials
        editItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(showEditPageVC))
        self.navigationItem.rightBarButtonItem = editItem
        
        // Wrap the table in a view to add a shadow
        view.addSubview(containerView)
        containerView.backgroundColor = UIColor(red: 62/255, green: 165/255, blue: 176/255, alpha: 1)
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor(red: 145, green: 145, blue: 145).cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowRadius = 3
        containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        
        addViewConstraints()
        
        containerView.addSubview(table)
        table.delegate = self
        table.dataSource = self
        table.register(viewInfoPageTableCell.self, forCellReuseIdentifier: "datacell")                          //Register the cell
        table.isScrollEnabled = false                                                                           //Disable scrolling
        table.separatorColor = .white
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.backgroundColor = UIColor(red: 62/255, green: 165/255, blue: 176/255, alpha: 1)
        table.layer.cornerRadius = 20
        table.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: table.frame.size.width, height: 1))     //Remove last separator
        
        addTableConstraints()
        
        // Set up the header label
        view.addSubview(headerLabel)
        headerLabel.attributedText = NSAttributedString(string: "Credentials", attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 34),
            NSAttributedString.Key.foregroundColor: UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1)
        ])
        headerLabel.adjustsFontSizeToFitWidth = true
        
        addLabelConstraints()
        
        // Set up the menu
        view.addSubview(menuButton)
        menuButton.setImage(UIImage(systemName: "text.justify"), for: .normal)
        menuButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        menuButton.contentHorizontalAlignment = .right
        menuButton.contentVerticalAlignment = .fill
        menuButton.tintColor = headerLabel.textColor
    
        addMenuConstraints()
        menuButton.addTarget(self, action: #selector(menuClicked), for: .touchUpInside)
        
        
        // Set up the collection view
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 4
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .white
        collectionView?.register(NewCredentialCollectionCell.self, forCellWithReuseIdentifier: "datacell")
        
        view.addSubview(collectionView!)
        addCollectionViewConstraints()
    }
    
    //MARK: asset constraints
    
    /*
        @addViewConstraints
        Adds constraints to the container view
     */
    func addViewConstraints(){
        //Add constraints
        heightOfTable = view.frame.height / 2.4
        heightOfTable = findNextFourFactor(heightOfTable)               //Finds the next value closest value that is divisible by four. Done to render the table better
        let topConstraint: CGFloat = view.frame.height / 6.49
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.heightAnchor.constraint(equalToConstant: heightOfTable).isActive = true
        containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: topConstraint + 100).isActive = true  //OG: 50
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
    }
    
    /*
        @addTableConstraints
        Adds constraints to the table in this scene
     */
    func addTableConstraints() {
        //Add constraints
        heightOfTable = view.frame.height / 2.4
        heightOfTable = findNextFourFactor(heightOfTable)               //Finds the next value closest value that is divisible by four. Done to render the table better
        
        table.translatesAutoresizingMaskIntoConstraints = false
        table.heightAnchor.constraint(equalToConstant: heightOfTable).isActive = true
        table.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        table.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        table.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
    }
    
    /*
        @addCollectionViewConstraints
        Adds constraints to the collection view
     */
    func addCollectionViewConstraints(){
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: -12).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -4).isActive = true
        collectionView?.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        collectionView?.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4).isActive = true
    }
    
    /*
        @addMenuConstraints
        Adds a different set of constraints to the menu button
     */
    func addMenuConstraints(){
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height / 6.42631).isActive = true
        menuButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        //menuButton.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: view.frame.height / -46.88889).isActive = true
        
        menuButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        menuButton.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 50).isActive = true
    }
    
    /*
        @addLabelConstraints
        Adds constraints to a label
     */
    func addLabelConstraints(){
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.heightAnchor.constraint(equalToConstant: 65).isActive = true
        headerLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width / 1.85).isActive = true
        headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: self.view.frame.height / 6.892).isActive = true
        headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12).isActive = true
    }
    
    // MARK: objc functions
    
    /*
        @showEditPageVC
        Switches between two states of editing and saving mode. Editing mode will allow ediitng and saving permissions.
     */
    @objc func showEditPageVC(){
        let cells = table.visibleCells
        (cells[3] as! viewInfoPageTableCell).key = (cells[0] as! viewInfoPageTableCell).infoLabelTF.text! + "_" + (cells[2] as! viewInfoPageTableCell).infoLabelTF.text!
        (cells[3] as! viewInfoPageTableCell).eyeButton.sendActions(for: .touchUpInside)
        
        //If the navigation text is "Save", save all the inputs
        if editItem.title == "Save"{
            let password = (cells[3] as! viewInfoPageTableCell).infoLabelTF.text!
            let oldName = credentialDetails?.name
            let oldUser = credentialDetails?.username
            
            //Can't have a password that is all pound signs. Possible additonal could be strong password protection
            guard password != String(repeating: "*", count: password.count) else{
                return
            }
            
            //Save to core data
            let newEntry = UserKey(context: PersistenceManager.context)
            newEntry.name = (cells[0] as! viewInfoPageTableCell).infoLabelTF.text
            newEntry.website = (cells[1] as! viewInfoPageTableCell).infoLabelTF.text
            newEntry.username = (cells[2] as! viewInfoPageTableCell).infoLabelTF.text
            if categoryIndex != IndexPath(){
                newEntry.category = Categories.categories[categoryIndex.row]
            }
            
            PersistenceManager.context.delete(credentialDetails!)
            PersistenceManager.saveContext()
            companyNames.container[indexPath!] = newEntry
            
            //Save to keychain
            let oldKey = oldName! + "_" + oldUser!
            let newKey = (cells[0] as! viewInfoPageTableCell).infoLabelTF.text! + "_" + (cells[2] as! viewInfoPageTableCell).infoLabelTF.text!
            KeychainWrapper.standard.removeObject(forKey: oldKey)                                                    //Delete old password
            KeychainWrapper.standard.set((cells[3] as! viewInfoPageTableCell).infoLabelTF.text!, forKey: newKey)     //Add new password
            credentialDetails = newEntry
            
            //Alert the user that the changes have been saved
            let alertController = UIAlertController(title: "Saved!", message: nil, preferredStyle: .alert)
            self.present(alertController, animated: true)
            
            //Using GCD as my timer.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.86) {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        //Enables editing in the text field depending on either of the two states
        for cell in cells{
            if let castedCell = cell as? viewInfoPageTableCell{
                castedCell.infoLabelTF.isUserInteractionEnabled = editItem.title == "Edit" ?  true :  false
            }
        }
        
        //Update the text on the navigation controller depending on the state and dismiss the keyboard
        DispatchQueue.main.async {
            self.editItem.title = self.editItem.title == "Edit" ? "Save" : "Edit"
            self.view.endEditing(true)
        }
    }
    
    /*
        @menuClicked
        Show a menu when the ellipsis are clicked
     */
    @objc func menuClicked(){
        let menu = UIMenu(title: "", children: [
            UIAction(title: "Generate New Password", image: UIImage(systemName: "key"), handler: { [weak self] _ in
                //Redirect to the password generator view controller
                let next: PasswordGeneratorPageVC = self?.storyboard?.instantiateViewController(identifier: "passwordGeneratorPageVC") as! PasswordGeneratorPageVC
                self!.view.endEditing(true)
                
                DispatchQueue.main.async {
                    self?.navigationController?.pushViewController(next, animated: true)
                }
            }),
            
            UIAction(title: "Create Reminder", image: UIImage(systemName: "calendar.badge.plus"), handler: { [weak self] _ in
                //Redirect to the reminder view controller
                let vc = CreateReminderPageVC()
                vc.modalPresentationStyle = .overCurrentContext
                vc.credentialDetails = self!.credentialDetails
                self?.present(vc, animated: false)
                
            }),
            
            UIAction(title: "Delete", image: UIImage(systemName: "trash"), handler: { [weak self] _ in
                //Alert the user that they are about to delete the credential
                let confirmationAlert = UIAlertController(title: "Confirmation", message: "Press confirm to delete.", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                    //Switch state to deleting
                    infoDeleteState.deleting = true
                    
                    //Activate biometrics
                    let context = LAContext()
                    var error: NSError? = nil
                    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error){
                        //Can use authentication
                        let reason: String = "Please allow to authenticate."
                        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, error in
                            DispatchQueue.main.async { [self] in
                                infoDeleteState.deleting = false
                                
                                guard success, error == nil else{
                                    //Unsuccessful authentication
                                    return
                                }
                                
                                //Successful authentication
                                
                                //Delete from Keychain
                                let key = (self!.credentialDetails?.name)! + "_" + (self!.credentialDetails?.username)!
                                KeychainWrapper.standard.removeObject(forKey: key)
                                
                                //Delete from Core Data
                                PersistenceManager.context.delete(self!.credentialDetails!)
                                PersistenceManager.saveContext()
                                
                                //Delete from view
                                companyNames.container.remove(at: self!.indexPath!)
                                
                                //Dismiss the view
                                self?.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                    else{
                        //Cannot use authentication
                        let alertController = UIAlertController(title: "Unavailable", message: "Cannot use this feature", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        
                        alertController.addAction(cancelAction)
                        self!.present(alertController, animated: true, completion: nil)
                    }
                }
                
                confirmationAlert.addAction(cancelAction)
                confirmationAlert.addAction(deleteAction)
                self!.present(confirmationAlert, animated: true)
            })
        ])
        
        menuButton.menu = menu
        menuButton.showsMenuAsPrimaryAction = true
    }
    
    // MARK: quality of life functions
    
    /*
        @textFieldShouldReturn
        Keyboard hides when the return button is pressed
        -- textField: textfield currently being edited on
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    /*
        @touchesBegan
        Keyboard hides when the user touches the screen outside of the keyboard
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
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

// MARK: table functions for viewInfoPage
extension ViewInfoPageVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4    //Number of items to present (title, username, password, wesbite)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Customize the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "datacell", for: indexPath) as! viewInfoPageTableCell
        cell.selectionStyle = .none                                                         //Disable selection highlight
        cell.key = (credentialDetails?.name)! + "_" + (credentialDetails?.username)!        //Pass the key to the cell to get the password when show is clicked
        cell.infoLabelTF.font = UIFont.systemFont(ofSize: 17)
        cell.infoLabelTF.delegate = self
        cell.parentVC = self
        
        //Customize the text labels of the cell
        if indexPath.row == 0 {
            cell.titleLabel.attributedText = NSAttributedString(string: "Title", attributes: [
                                                                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)] )
            cell.infoLabelTF.attributedText = NSAttributedString(string: (credentialDetails?.name)!, attributes: [
                                                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19)])
            cell.eyeButton.isHidden = true
            cell.copyButton.isHidden = true
        } 
        else if indexPath.row == 1 {
            cell.titleLabel.attributedText = NSAttributedString(string: "Website", attributes: [
                                                                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)] )
            cell.infoLabelTF.attributedText = NSAttributedString(string: (credentialDetails?.website)!, attributes: [
                                                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19)])
            cell.eyeButton.isHidden = true
            cell.copyButton.isHidden = true
        }
        else if indexPath.row == 2 {
            cell.titleLabel.attributedText = NSAttributedString(string: "Username", attributes: [
                                                                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)] )
            cell.infoLabelTF.attributedText = NSAttributedString(string: (credentialDetails?.username)!, attributes: [
                                                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19)])
            cell.infoLabelTF.autocapitalizationType = .none
            cell.eyeButton.isHidden = true
        }
        else if indexPath.row == 3 {
            cell.titleLabel.attributedText = NSAttributedString(string: "Password", attributes: [
                                                                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)] )
            let censor = String(repeating: "*", count: KeychainWrapper.standard.string(forKey: (credentialDetails?.name)! + "_" + (credentialDetails?.username)!)!.count)
            cell.infoLabelTF.attributedText = NSAttributedString(string: censor, attributes: [
                                                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19)])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightOfTable / 4
    }

}

// MARK: collection view function

extension ViewInfoPageVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    /*
        @numberOfItemsInSection
        Returns the number of cells
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Categories.categories.count
    }
    
    /*
        @cellForItemAt
        Returns a cell to show
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "datacell", for: indexPath) as! NewCredentialCollectionCell
        
        if indexPath != categoryIndex{
            cell.backgroundColor = UIColor(red: 74, green: 181, blue: 193)// UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1)
            cell.transform = .identity
        }
        cell.layer.cornerRadius = 13
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOpacity = 1
        cell.layer.shadowRadius = 1
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.categoryLabel.text = Categories.categories[indexPath.row]
        if cell.categoryLabel.text == credentialDetails?.category && !newCategorySelected{
            cell.backgroundColor = UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1)
            cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            categoryIndex = indexPath
        }
        
        return cell
    }
    
    /*
        @sizeForItemAt
        Returns the size of the cell
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: Double = 118
        if Categories.categories[indexPath.row].count > 12{
            width = Double(Categories.categories[indexPath.row].count) * 9.5
        }
        else if Categories.categories[indexPath.row].count < 6{
            width = Double(Categories.categories[indexPath.row].count) * 14.5
        }
        return CGSize(width: width, height: 40)
    }
    
    /*
        @didSelectItemAt
        Selects a cell to choose a category to save as
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Animate the click of the new cell and update the index variable
        let newCell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.17) {
            newCell?.backgroundColor = UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1)
            newCell?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
        categoryIndex = indexPath
        newCategorySelected = (collectionView.cellForItem(at: indexPath) as! NewCredentialCollectionCell).categoryLabel.text == credentialDetails?.category ? false : true

        //Animate the deselection of the old cell. Only keep one cell highlighted
        for i in 0...6{
            let oldCell = collectionView.cellForItem(at: IndexPath(item: i, section: 0))
            if oldCell?.backgroundColor == UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1) && i != indexPath.row{
                collectionView.performBatchUpdates {
                    UIView.animate(withDuration: 0.17) {
                        oldCell?.backgroundColor = UIColor(red: 74, green: 181, blue: 193)
                        oldCell?.transform = .identity
                    }
                }
            }
        }
        /*
        if oldIndex != categoryIndex{
            let oldCell = collectionView.cellForItem(at: oldIndex)
            collectionView.performBatchUpdates {
                UIView.animate(withDuration: 0.17) {
                    oldCell?.backgroundColor = UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1)
                    oldCell?.transform = .identity
                }
            }
        }
         */
    }
}
