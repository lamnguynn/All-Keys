//
//  HomePageV.swift
//  All Pass
//
//  Created by Lam Nguyen on 7/7/21.
//

import UIKit
import SwiftKeychainWrapper

class NewCredentialPage: HalfPageModalViewController, UITextFieldDelegate {
    
    // MARK: asset initialization
    let table = UITableView()                       //Table to display the text fields
    let saveButton = UIButton()                     //Button to save the credentials provided
    let headerLabel = UILabel()                     //Label to show the scenes title
    var collectionView: UICollectionView?
    var heightOfTable: CGFloat = 0                  //Value for the height of the table
    var homePage: HomePageVC!                       //Table from the home page. Used to update its contents
    var categoryIndex: IndexPath = IndexPath()      //Value for the index of a category
    
    
    // MARK: view life cycle
    override func viewDidLoad() {
        /* Set up the half modal view controller */
        defaultHeight = 445
        dismissibleHeight = 320
        currentContainerHeight = defaultHeight
        super.viewDidLoad()
        containerView.backgroundColor = .white
        
        /* Set up the header label */
        setUpHeaderLabel()
        
        /* Set up the table */
        setUpTable()
        
        /* Set up the save button */
        setUpSaveButton()
        
        /* Set up the collection */
        setUpCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification: )), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification: )), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: asset setup
    /*
        @setUpTable
        Sets up the table
     */
    func setUpTable(){
        containerView.addSubview(table)
        table.delegate = self
        table.dataSource = self
        table.register(NewCredentialPageTableCell.self, forCellReuseIdentifier: "datacell")
        table.isScrollEnabled = false                                                                           //Disable scrolling
        table.separatorStyle = .none
        table.backgroundColor = .white  //UIColor(red: 62/255, green: 165/255, blue: 176/255, alpha: 1)
        table.layer.cornerRadius = 16
        table.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: table.frame.size.width, height: 1))     //Remove last separator
        addTableConstraints()
    }
    
    /*
        @setUpCollectionView
        Sets up the collection view
     */
    func setUpCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 4
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .white//UIColor(red: 242, green: 242, blue: 242)
        collectionView?.layer.cornerRadius = 13
        collectionView?.register(NewCredentialCollectionCell.self, forCellWithReuseIdentifier: "datacell")
        
        containerView.addSubview(collectionView!)
        addCollectionViewConstraints()
    }
    
    /*
        @setUpHeaderLabel
        Sets up the header label
     */
    func setUpHeaderLabel(){
        containerView.addSubview(headerLabel)
        headerLabel.attributedText = NSAttributedString(string: "New Password", attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 34),
            NSAttributedString.Key.foregroundColor: UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1)
        ])
        headerLabel.adjustsFontSizeToFitWidth = true
        addLabelConstraints()
    }
    
    /*
        @setUpSaveButton
        Sets up the save button
     */
    func setUpSaveButton(){
        containerView.addSubview(saveButton)
        saveButton.backgroundColor = UIColor(red: 62/255, green: 165/255, blue: 176/255, alpha: 1)
        saveButton.setImage(UIImage(systemName: "plus"), for: .normal)
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 10
        addButtonConstraints()
        saveButton.addTarget(self, action: #selector(saveClicked), for: .touchUpInside)
    }
    
    
    
    // MARK: asset constraints
    
    /*
        @addLabelConstraints
        Adds constraints to a label
     */
    func addLabelConstraints(){
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20).isActive = true
        headerLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12).isActive = true
    }
    
    /*
        @addCollectionViewConstraints
        Adds constraints to the collection view
     */
    func addCollectionViewConstraints(){
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12).isActive = true
        collectionView?.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5).isActive = true
        collectionView?.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: table.topAnchor, constant: 0).isActive = true
    }
    
    /*
        @addTableConstraints
        Adds constraints to the table
     */
    func addTableConstraints(){
        heightOfTable = currentContainerHeight - 50 - 50 - 4
        
        table.translatesAutoresizingMaskIntoConstraints = false
        table.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 110).isActive = true //OG: 60
        table.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        table.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
        table.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
    }
    
    /*
        @addButtonConstraints
        Adds constraints to the save button
     */
    func addButtonConstraints(){
        let width = (self.view.frame.width / 5) - 5

        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        saveButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        saveButton.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 10).isActive = true

    }
    
    // MARK: objc functions
    
    /*
        @saveClicked
        Check credentials for errors and save to core data and keychain
     */
    @objc func saveClicked(){
        //Assign the text field to variables
        let cells = table.visibleCells
        let title = (cells[0] as! viewInfoPageTableCell).infoLabelTF
        let website = (cells[1] as! viewInfoPageTableCell).infoLabelTF
        let username = (cells[2] as! viewInfoPageTableCell).infoLabelTF
        let password = (cells[3] as! viewInfoPageTableCell).infoLabelTF
        
        //Check to see any of the fields are empty and alert the user.
        guard title.text != "" && username.text != "" && password.text != "" else{
            //If a text field is empty, alert the user by performing a shake animation
            if(title.text == ""){
                shakeAnimation((cells[0] as! viewInfoPageTableCell).titleLabel)
            }
            if(username.text == ""){
                shakeAnimation((cells[2] as! viewInfoPageTableCell).titleLabel)
            }
            if(password.text == ""){
                shakeAnimation((cells[3] as! viewInfoPageTableCell).titleLabel)
            }
            
            return
        }
        
        //If the username is not avaliable, alert the user
        guard isUsernameAvailable(title.text!, username.text!) else{
            let alertController = UIAlertController(title: "Credentials already exist!", message: "Click continue to update", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let continueAction = UIAlertAction(title: "Continue", style: .default) { action in
                //If user wants to change, simply delete the old entry in keychain and add a new one
                let key = title.text! + "_" + username.text!
                
                KeychainWrapper.standard.removeObject(forKey: key)
                KeychainWrapper.standard.set(password.text!, forKey: key)
                
                //Exit the controller when done
                DispatchQueue.main.async {
                    self.animateDismissView()
                }
            }
            
            
            alertController.addAction(cancelAction)
            alertController.addAction(continueAction)
            self.present(alertController, animated: true)
            
            return
        }
        
        //Save the username to Core Data
        let userKey = UserKey(context: PersistenceManager.context)
        userKey.name = title.text
        userKey.website = website.text
        userKey.username = username.text
        if categoryIndex != IndexPath(){
            userKey.category = Categories.categories[categoryIndex.row]
        }
        PersistenceManager.saveContext()
        
        //Save the password to Keychain
        let key: String? = title.text! + "_" + username.text!
        KeychainWrapper.standard.set(password.text!, forKey: key!)
    
        
        //Add the new entry into the container to display
        companyNames.container.append(userKey)
        
        //Dismiss the view controller by performing an animation and dismiss; and add to view
        DispatchQueue.main.async {
            self.view.endEditing(true)
            
            if self.homePage.filteredCompany.count == 0{
                let indexPath = IndexPath(row: companyNames.container.count - 1, section: 0)
                self.homePage.table.insertRows(at: [indexPath], with: .fade)
            }
            self.homePage.hideEmptyHomeItems()
            self.animateDismissView()
        }
        
    }
    
    
    /*
        @keyboardWillAppear
        Raise the height of the container if the keyboard is up
     */
    @objc func keyboardWillAppear(notification: NSNotification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
            return
        }
        
        //Animate the container view up
        let newHeight = keyboardFrame.height + defaultHeight
        animateContainerHeight(newHeight)
    }
    
    /*
        @keyboardWillDisappear
        Lower the height of the container if the keyboard is dismissed
     */
    @objc func keyboardWillDisappear(notification: NSNotification) {
        animateContainerHeight(defaultHeight)
        
    }
    
    /*
        @handlePanGesture
        Overrided the function to disable the view controller expanding up when scrolling up
     */
    override func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // drag to top will be minus value and vice versa
        
        //Update the height based on value of dragging
        let newHeight = currentContainerHeight - translation.y
        
        //Perform animations depending on the state of the gesture and the height of the container
        switch gesture.state {
            case .changed:
                /* User is dragging*/
                
                if newHeight < defaultHeight{
                    containerViewHeightConstraint?.constant = newHeight
                    view.layoutIfNeeded()
                }
            case .ended:
                /* User stop dragging*/
                
                if newHeight < dismissibleHeight{                                   //C1: New height is below the minimum, dismiss the view
                    self.animateDismissView()
                }
                else if newHeight < defaultHeight{                                  //C2: New height is below default, then animate back to default
                    animateContainerHeight(defaultHeight)
                }
            default:
                break
            }
    }
    
    // MARK: supporting functions
    
    /*
        @shakeAnimation
        Create a shaking animation
        -- item: the view to animate
     */
    func shakeAnimation(_ item: UIView){
        item.transform = CGAffineTransform(translationX: 8, y: 0)
        UIView.animate(withDuration: 0.15) {
            item.transform = CGAffineTransform(translationX: -8, y: 0)
        } completion: { completion in
            item.transform = .identity
        }
    }
    
    /*
     Retuns if the username is avaliable provided is original
     -- username: the username the user provides to check
     */
    func isUsernameAvailable(_ name: String, _ username: String) -> Bool{
        for entries in companyNames.container{
            if entries.name?.lowercased() == name.lowercased() && entries.username?.lowercased() == username.lowercased(){
                return false
            }
        }
        
        return true
    }
    
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
    
    

}

// MARK: table functions
extension NewCredentialPage: UITableViewDelegate, UITableViewDataSource{
    
    /*
        @cellForRowAt
        Builds a cell and returns it
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Customize the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "datacell") as! NewCredentialPageTableCell
        cell.selectionStyle = .none                                                             //Disable selection highlight
        cell.backgroundColor = .white                                                           //Change background color
        cell.contentView.backgroundColor = .white
        cell.infoLabelTF.isUserInteractionEnabled = true
        cell.infoLabelTF.delegate = self
        cell.infoLabelTF.textColor = .black
        cell.infoLabelTF.layer.cornerRadius = 10
        cell.infoLabelTF.backgroundColor = UIColor(red: 242, green: 242, blue: 242)
        cell.infoLabelTF.setLeftPaddingPoints(5)
        cell.titleLabel.textColor = .darkGray
        
        //Customize the text labels of the cell
        cell.eyeButton.isHidden = true
        cell.copyButton.isHidden = true
        cell.copyButton.tintColor = UIColor(red: 62/255, green: 165/255, blue: 176/255, alpha: 1)
        
        let infoLabelAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.5),
                          NSAttributedString.Key.foregroundColor: UIColor.gray]
        let titleLabelAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)]
        
        if indexPath.row == 0 {
            cell.titleLabel.attributedText = NSAttributedString(string: "Title", attributes: titleLabelAttributes)
            cell.infoLabelTF.attributedPlaceholder = NSAttributedString(string: "Enter title:", attributes: infoLabelAttributes)
        }
        else if indexPath.row == 1 {
            cell.titleLabel.attributedText = NSAttributedString(string: "Website", attributes: titleLabelAttributes)
            cell.infoLabelTF.attributedPlaceholder = NSAttributedString(string: "Enter website (optional):", attributes: infoLabelAttributes)
        }
        else if indexPath.row == 2 {
            cell.titleLabel.attributedText = NSAttributedString(string: "Username", attributes: titleLabelAttributes)
            cell.infoLabelTF.attributedPlaceholder = NSAttributedString(string: "Enter username:", attributes: infoLabelAttributes)
            cell.infoLabelTF.autocapitalizationType = .none
        }
        else if indexPath.row == 3 {
            cell.titleLabel.attributedText = NSAttributedString(string: "Password", attributes: titleLabelAttributes)
            cell.copyButton.isHidden = false
            cell.copyButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
            cell.infoLabelTF.attributedPlaceholder = NSAttributedString(string: "Enter password:", attributes: infoLabelAttributes)
            //cell.infoLabelTF.isSecureTextEntry = true
        }
          
        return cell
    }
    
    /*
        @numberOfRowsInSection
        Returns the number of cells in the table
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    /*
        @heightForRowAt
        Returns the value of the height of a cell
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (heightOfTable - 30) / 4
    }
}

// MARK: collection functions

extension NewCredentialPage: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
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
            cell.backgroundColor = UIColor(red: 74, green: 181, blue: 193)
            cell.transform = .identity
        }
        cell.layer.cornerRadius = 13
        cell.layer.shadowColor = UIColor(red: 200, green: 200, blue: 200).cgColor
        cell.layer.shadowOpacity = 1
        cell.layer.shadowRadius = 1
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.categoryLabel.text = Categories.categories[indexPath.row]
        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 10)
    }
    
    /*
        @didSelectItemAt
        Selects a cell to choose a category to save as
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let oldIndex = categoryIndex
        
        //Animate the click of the new cell and update the index variable
        let newCell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.17) {
            newCell?.backgroundColor = UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1)// UIColor(red: 74, green: 181, blue: 193)
            newCell?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
        categoryIndex = indexPath

        //Animate the deselection of the old cell
        if oldIndex != categoryIndex{
            let oldCell = collectionView.cellForItem(at: oldIndex)
            collectionView.performBatchUpdates {
                UIView.animate(withDuration: 0.17) {
                    oldCell?.backgroundColor = UIColor(red: 74, green: 181, blue: 193)
                    oldCell?.transform = .identity
                }
            }
        }

    }
    
    
}
