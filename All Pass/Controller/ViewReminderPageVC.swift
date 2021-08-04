//
//  ViewReminderPageVC.swift
//  All Pass
//
//  Created by Lam Nguyen on 7/9/21.
//


/*
    TO IMPLEMENT:
    - change expiration date of reminder to three days
    - add feature to be able to directly change tht password
 */


import UIKit

class ViewReminderPageVC: HalfPageModalViewController, UITextViewDelegate{
    
    // MARK: asset initialization
    let headerLabel: UILabel = {                            
        let headerLabel = UILabel()
        
        return headerLabel
    }()
    
    lazy var disclaimerLabel: UILabel = {
        let disclaimerLabel = UILabel()
        let attributes = [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 14),
                          NSAttributedString.Key.foregroundColor: UIColor.red]
        
        disclaimerLabel.attributedText = NSAttributedString(string: "* Reminder will be deleted in three days", attributes: attributes)
        
        return disclaimerLabel
    }()
    
    let descTextView: UITextView = {
        let descTextView = UITextView()
        descTextView.backgroundColor = UIColor(red: 186, green: 186, blue: 186)
        
        return descTextView
    }()
    
    let timeTable: UITableView = {
        let timeTable = UITableView()
        
        return timeTable
    }()
    
    var reminderDetails: ReminderEntry!
    var reminderCenter: ReminderCenterPageVC!
    var tableTopConstraints: CGFloat = 2
    
    // MARK: view life cycle
    override func viewDidLoad() {
        defaultHeight = 410
        currentContainerHeight = 410
        dismissibleHeight = 300
        super.viewDidLoad()
        
        // Set up the header label
        containerView.addSubview(headerLabel)
        headerLabel.attributedText = NSAttributedString(string: reminderDetails.title!, attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 36),
            NSAttributedString.Key.foregroundColor: UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1)
        ])
        headerLabel.adjustsFontSizeToFitWidth = true
        
        addLabelConstraints(headerLabel, containerView.topAnchor, 20, -12)
        
        // Set up the disclaimer label. Only show when the date is passed
        if reminderDetails.date! < Date(){
            disclaimerLabel.isHidden = false
            tableTopConstraints = 16
            containerView.addSubview(disclaimerLabel)
            
            addLabelConstraints(disclaimerLabel, headerLabel.bottomAnchor, 0, -12)
        }
        else{ disclaimerLabel.isHidden = true }
        
        // Set up the time table
        containerView.addSubview(timeTable)
        timeTable.delegate = self
        timeTable.dataSource = self
        timeTable.register(ViewReminderPageTableCell.self, forCellReuseIdentifier: "datacell")
        timeTable.separatorStyle = .none
        timeTable.isScrollEnabled = false
        timeTable.backgroundColor = .white
        
        addTableConstraints()
        
        // Set up the description text view
        containerView.addSubview(descTextView)
        descTextView.backgroundColor = UIColor(red: 223, green: 223, blue: 223)
        descTextView.layer.cornerRadius = 20
        descTextView.text = reminderDetails.desc
        descTextView.delegate = self
        descTextView.textColor = .gray
        descTextView.setLeftPaddingPoints()
        addSaveButton()
        
        addTextViewConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification: )), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification: )), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: asset constraints
    
    /*
        @addLabelConstraints
        Adds constraints to the header label
     */
    func addLabelConstraints(_ label: UILabel, _ topConstraint: NSLayoutYAxisAnchor, _ topConstant: CGFloat, _ trailingConstant: CGFloat){
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: topConstraint, constant: topConstant).isActive = true
        label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12).isActive = true
        label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: trailingConstant).isActive = true
        
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
    }
    
    /*
        @addTableConstraints
        Adds constraints to the table
     */
    func addTableConstraints(){
        timeTable.translatesAutoresizingMaskIntoConstraints = false
        timeTable.heightAnchor.constraint(equalToConstant: 165).isActive = true
        timeTable.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: tableTopConstraints).isActive = true
        timeTable.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        timeTable.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
    }
    
    /*
        @addTextViewConstraints
        Adds constraints to the description text view
     */
    func addTextViewConstraints(){
        descTextView.translatesAutoresizingMaskIntoConstraints = false
        descTextView.heightAnchor.constraint(equalToConstant: 110).isActive = true
        descTextView.topAnchor.constraint(equalTo: timeTable.bottomAnchor, constant: 10).isActive = true
        descTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        descTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
    }
    
    // MARK: objc functions
    
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
        @saveNotes
        Saves the updates note if needed
     */
    @objc func saveNotes(){
        //If the text is updated/different, then update the entry in core data
        if reminderDetails.desc != descTextView.text {
            reminderDetails.desc = descTextView.text
            
            //Update entry
            PersistenceManager.saveContext()
        }
        
        view.endEditing(true)
    }
    
    // MARK: keyboard functions
    
    /*
        @addSaveButton
        Adds a done button to the keyboard
     */
    func addSaveButton(){
        let toolBar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let saveButton: UIBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveNotes))
        //let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolBar.setItems([flexSpace, saveButton], animated: false)
        toolBar.sizeToFit()
        self.descTextView.inputAccessoryView = toolBar
    }
    
}

// MARK: table functions

extension ViewReminderPageVC: UITableViewDelegate, UITableViewDataSource{
    
    /*
        @numberOfRowsInSection
        Returns the number of cells there are
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    /*
        @cellForRowAt
        Builds a cell and returns it to display
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Customize the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "datacell", for: indexPath) as! ViewReminderPageTableCell
        cell.selectionStyle = .none
        cell.backgroundColor = timeTable.backgroundColor
        cell.copyButton.isHidden = true
        
        //Customize the image
        if indexPath.row == 0{
            let image = UIImage(systemName: "calendar") 
            cell.imageV.image = image
            cell.imageV.contentMode = .scaleAspectFit
            cell.imageV.tintColor = .white
            cell.imageV.backgroundColor = UIColor(red: 252, green: 56, blue: 62)
            cell.imageV.layer.cornerRadius = 9
            
            cell.titleLabel.attributedText = buildText("Date", color: UIColor.gray)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/YYYY"
            let dateString = dateFormatter.string(from: reminderDetails.date!)
            cell.infoLabel.attributedText = buildText(dateString, color: UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1))
        }
        else if indexPath.row == 1{
            let image = UIImage(systemName: "clock.fill")
            let iV = UIImageView(image: image)
            iV.frame = CGRect(x: 3, y: 4, width: 32, height: 30)
            iV.backgroundColor = .clear
            iV.contentMode = .scaleAspectFit
            
            cell.imageV.insertSubview(iV, at: 0)
            cell.imageV.tintColor = .white
            cell.imageV.backgroundColor = UIColor(red: 56, green: 121, blue: 252)
            cell.imageV.layer.cornerRadius = 9
            
            cell.titleLabel.attributedText = buildText("Time", color: UIColor.gray)
            
            let dateFormatter = DateFormatter()
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            dateFormatter.dateFormat = "hh:mm a"
            let dateString = dateFormatter.string(from: reminderDetails.date!)
            cell.infoLabel.attributedText = buildText(dateString, color: UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1))
        }
        else if indexPath.row == 2{
            let image = UIImage(systemName: "lock.fill")
            let iV = UIImageView(image: image)
            iV.frame = CGRect(x: 3, y: 4, width: 32, height: 30)
            iV.backgroundColor = .clear
            iV.contentMode = .scaleAspectFit
            
            cell.imageV.insertSubview(iV, at: 0)
            cell.imageV.tintColor = .white
            cell.imageV.backgroundColor = UIColor(red: 186, green: 186, blue: 186)
            cell.imageV.layer.cornerRadius = 9
            
            cell.titleLabel.attributedText = buildText("Suggested Password", color: UIColor.gray)
            let passwordVC = PasswordGeneratorPageVC()
            let passwordText = passwordVC.createPassword(lower: password.savedSettings[0].lowerCase,
                                                         upper: password.savedSettings[0].upperCase,
                                                         numbers: password.savedSettings[0].numbers,
                                                         specialChar: password.savedSettings[0].specialChar,
                                                         length: password.savedSettings[0].length)
            cell.infoLabel.attributedText = buildText(passwordText, color: UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1))
            
            cell.copyButton.isHidden = false
            let copyImage: UIImage? = UIImage(systemName: "doc.on.doc.fill")
            cell.copyButton.setImage(copyImage, for: .normal)
            cell.copyButton.tintColor = UIColor(red: 70/255, green: 172/255, blue: 183/255, alpha: 1)
            cell.copyButton.addTarget(self, action: #selector(copyClicked), for: .touchUpInside)
        }
        
        return cell
    }
    
    /*
        @heightForRowAt
        Returns a value for the height of the cell
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    /*
        @buildText
        Builds an attributed string with the given arguments
        -- title: text to display
        -- color: color of the text
     */
    func buildText(_ title: String, color: UIColor) -> NSAttributedString{
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15),
                          NSAttributedString.Key.foregroundColor: color]
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    /*
        @copyClicked
        Copys to the clipboard when the copy button is clicked
     */
    @objc func copyClicked(){
        //Show an alert for 1 seconds
        let alertController = UIAlertController(title: "Copied!", message: nil, preferredStyle: .alert)
        self.present(alertController, animated: true)
        
        //Using GCD as my timer. Quite overkill as nothing is happening on the main thread.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.86) {
            self.dismiss(animated: true, completion: nil)
        }

        //Copy to clipboard
        let cell = timeTable.visibleCells
        let passwordText = (cell[2] as! ViewReminderPageTableCell).infoLabel.text
        UIPasteboard.general.string = passwordText
    }
    
}
