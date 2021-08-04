//
//  CreateReminderPageVC.swift
//  All Pass
//
//  Created by Lam Nguyen on 7/5/21.
//

import Foundation
import UIKit
import CoreData

class CreateReminderPageVC: UIViewController, UITextFieldDelegate{
    
    // MARK: asset initialization
    lazy var datePicker: UIDatePicker = {                                           //Date Picker to allow user to pick date of reminder
        let datePicker = UIDatePicker()
        datePicker.tintColor = .gray
        return datePicker
    }()
     
    lazy var containerView: UIView = {                                              //Container view to store assets
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    let maxDimAlpha: CGFloat = 0.6                                                  //Maximum alpha value for the dimmed view
    lazy var dimmedView: UIView = {                                                 //Dimmed view
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimAlpha
        
        return view
    }()
    
    lazy var headerLabel: UILabel = {                                               //Label to show the header
        let headerLabel = UILabel()
        headerLabel.attributedText = NSAttributedString(string: "New Reminder", attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 34),
            NSAttributedString.Key.foregroundColor: UIColor(red: 152, green: 152, blue: 152)
        ])
        headerLabel.adjustsFontSizeToFitWidth = true
        
        return headerLabel
    }()
    
    
    lazy var descriptionLabel: UILabel = {                                          //Label to show the description
        let descriptionLabel = UILabel()
        descriptionLabel.attributedText = NSAttributedString(string: "Create a new reminder to reset password", attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: UIColor.darkGray
        ])
        
        return descriptionLabel
    }()
    
    var credentialDetails: UserKey?                                                 //Credentials to reference and save
    lazy var titleTF: UITextField = {                                               //Text field to show the title of the remindeer
        let titleTF = UITextField()
        titleTF.placeholder = "Enter title: "
        titleTF.text = credentialDetails?.name
        titleTF.setLeftPaddingPoints(15)
        titleTF.layer.cornerRadius = 20
        titleTF.backgroundColor = UIColor(red: 62/255, green: 165/255, blue: 176/255, alpha: 1)
        titleTF.isUserInteractionEnabled = false
        titleTF.textColor = .white
        
        return titleTF
    }()
    
    lazy var clearButton: UIButton = {
        let clearButton = UIButton()
        clearButton.backgroundColor = UIColor(red: 62/255, green: 165/255, blue: 176/255, alpha: 1)
        clearButton.layer.cornerRadius = 20
        clearButton.setImage(UIImage(systemName: "trash"), for: .normal)
        clearButton.tintColor = .white
        
        return clearButton
    }()
    
    lazy var saveButton: UIButton = {                                               //Button to save the reminder
        let saveButton = UIButton()
        saveButton.backgroundColor = UIColor(red: 62/255, green: 165/255, blue: 176/255, alpha: 1)
        saveButton.layer.cornerRadius = 20
        saveButton.setImage(UIImage(systemName: "plus"), for: .normal)
        saveButton.tintColor = .white
        
        return saveButton
    }()
    
    lazy var descrTF: UITextField = {                                               //Text field to input any notes from user
        let descrTF = UITextField()
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor(red: 213, green: 213, blue: 213)
        ]
        descrTF.attributedPlaceholder = NSAttributedString(string: "Enter notes (optional): ", attributes: attributes)
        descrTF.setLeftPaddingPoints(15)
        descrTF.backgroundColor = UIColor(red: 62/255, green: 165/255, blue: 176/255, alpha: 1)
        descrTF.layer.cornerRadius = 20
        
        return descrTF
    }()
    
    let notificationCenter = UNUserNotificationCenter.current()                     //Notification center to set up notifications
    let defaultHeight: CGFloat = 375                                                //Default height of the container
    let dismissibleHeight: CGFloat = 220                                            //Height at which the container and view can be dismissed
    let maxmimumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64         //Maximum container height to show modally
    var currentContainerHeight: CGFloat = 375                                       //Current container height depending on gesture
    var containerViewBottomConstraint: NSLayoutConstraint?                          //Bottom constraint for container
    var containerViewHeightConstraint: NSLayoutConstraint?                          //Height constraint for the container
    
    // MARK: view life cycle
    override func viewDidLoad() {
        
        /* Set up the views */
        addViewConstraints()
        setupPanGesture()
        
        /* Set up the header label */
        containerView.addSubview(headerLabel)
        addLabelConstraints(headerLabel, containerView.topAnchor, 14)
        
        /* Set up the description label */
        containerView.addSubview(descriptionLabel)
        addLabelConstraints(descriptionLabel, headerLabel.bottomAnchor, 3)
        
        /* Set up the date picker */
        containerView.addSubview(datePicker)
        addDatePickerConstraints()
        
        /* Set up the title text field */
        containerView.addSubview(titleTF)
        titleTF.delegate = self
        addTextFieldConstraints(titleTF, 60, datePicker.bottomAnchor, -10)
        
        /* Set up the description text field*/
        containerView.addSubview(descrTF)
        descrTF.delegate = self
        descrTF.textColor = .white
        addTextFieldConstraints(descrTF, 120, titleTF.bottomAnchor, -90)
        
        /* Set up the cancel button */
        containerView.addSubview(clearButton)
        addButtonConstraint(clearButton, 10)
        
        /* Set up the save button */
        containerView.addSubview(saveButton)
        addButtonConstraint(saveButton, 74)
        saveButton.addTarget(self, action: #selector(saveClicked), for: .touchUpInside)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateDimmedView()
        animatePresentContainer()
        
        //Add observers to detect when the keyboard is up
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification: )), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification: )), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: asset constraints
    
    func addViewConstraints(){
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        
        //Add constraints to the dim and container view
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            //dimmedView constraints
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            //container constraints
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        containerViewBottomConstraint           = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        containerViewHeightConstraint           = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        containerViewBottomConstraint?.isActive = true
        containerViewHeightConstraint?.isActive = true
    }
    /*
        @addButtonConstraint
        Add constraints to a button
        -- button       : button to apply constraints to
        -- topConstant  : value for the top anchor constant
     */
    func addButtonConstraint(_ button: UIButton, _ topConstant: CGFloat){
        button.translatesAutoresizingMaskIntoConstraints = false
        button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        button.leadingAnchor.constraint(equalTo: descrTF.trailingAnchor, constant: 10).isActive = true
        button.heightAnchor.constraint(equalToConstant: 57).isActive = true
        button.topAnchor.constraint(equalTo: titleTF.bottomAnchor, constant: topConstant).isActive = true
    }
    
    /*
        @addTextFieldConstraints
        Adds constraints to a text field
        -- textField        :   text field to apply constraints to
        -- height           :   value for the height of the text field
        -- topAnchor        :   top anchor for the text field
        -- trailingConstant :   value for the trailing anchor constant
     */
    func addTextFieldConstraints(_ textField: UITextField, _ height: CGFloat, _ topAnchor: NSLayoutYAxisAnchor, _ trailingConstant: CGFloat){
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: height).isActive = true
        textField.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: trailingConstant).isActive = true
    }
    
    /*
        @addLabelConstraints
        Adds constraints to the header label
     */
    func addLabelConstraints(_ label: UILabel, _ topAnchor: NSLayoutYAxisAnchor, _ topConstant: CGFloat){
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: topConstant),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10)
        ])
    }
    
    /*
        @addDatePickerConstraints
        Adds constraints to the date picker
     */
    func addDatePickerConstraints(){
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
    }
    
    // MARK: objc functions
    @objc func saveClicked(){
        //Make sure the user has entered a title
        guard titleTF.text != "" else{
            shakeAnimation(titleTF)
            return
        }
        
        //Make sure the user does not set the notification to current time
        guard self.datePicker.date > Date() else{
            shakeAnimation(datePicker)
            return
        }
        
        
        //Check to see if user has authorized notification. If so, save notification and entry
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized{
                    /* User allowed notification */
                    
                    //Build the notification
                    let title = self!.titleTF.text
                    
                    let content = UNMutableNotificationContent()
                    content.title = title!
                    content.body = "Time to Reset Your Password!"
                    
                    let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self!.datePicker.date)
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    //Add the notification to the center
                    self!.notificationCenter.add(request) { error in
                        if error != nil{
                            print("error" + error.debugDescription)
                            return
                        }
                    }
                    
                    //Alert the user that the notification was successful and save to core data
                    let alertController = UIAlertController(title: "Added!", message: nil, preferredStyle: .alert)
                    self!.present(alertController, animated: true, completion: nil)
                    
                    let notifEntry = ReminderEntry(context: PersistenceManager.context)
                    notifEntry.date = self!.datePicker.date
                    notifEntry.desc = self!.descrTF.text
                    notifEntry.title = title
                    PersistenceManager.saveContext()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.86) {
                        self?.dismiss(animated: true, completion: nil)
                        self!.view.endEditing(true)
                        self!.animateDismissView()
                    }
                }
                else{
                    /* User did NOT allow notification */
                    
                    //Alert the user that they need to allow notifications in the settings
                    let alertController = UIAlertController(title: "Enable Notifications", message: "Please allow notifications in settings", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        //Open the settings when "Ok" is clicked
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else{
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsURL){
                            UIApplication.shared.open(settingsURL)
                        }
                    }))
                    self!.present(alertController, animated: true, completion: nil)
                }
            }
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
    
    // MARK: animations
    
    /*
        @animatePresentContainer
        Animates the container when it first appears
     */
    func animatePresentContainer(){
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    /*
        @animateDimmedView
        Animates the dimmed view when it first appears
     */
    func animateDimmedView(){
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimAlpha
        }
    }
    
    /*
        @animateDismissView
        Animates the hiding of the container and dimmed view
     */
    func animateDismissView(){
        //Hide container view
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            self.view.layoutIfNeeded()
        }
        
        //Hide dim view
        dimmedView.alpha = maxDimAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
    
    /*
        @animateContainerHeight
        Animates the container to a certain height
        -- height: height to animate to
     */
    func animateContainerHeight(_ height: CGFloat){
        UIView.animate(withDuration: 0.4) {
            self.containerViewHeightConstraint?.constant = height
            self.view.layoutIfNeeded()
        }
        
        currentContainerHeight = height
    }
    
    // MARK: gestures functions
    
    /*
        @setupPanGesture
        Creates a gesture to detect dragging and size the view accordingly
     */
    func setupPanGesture(){
        // Build a gesture and add it to the view
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        
        // Remove any delays to immediately listen to gesture movements
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
        
        //Add a gesture to the dimmed view so when clicked, the view controller is dismissed
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped(gesture:)))
        dimmedView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: objc functions
    
    /*
        @handlePanGesture
        Provide the right animations depending on the users drag gesture
     */
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // drag to top will be minus value and vice versa

        // get drag direction
        let isDraggingDown = translation.y > 0
        
        //Update the height based on value of dragging
        let newHeight = currentContainerHeight - translation.y
        
        //Perform animations depending on the state of the gesture and the height of the container
        switch gesture.state {
            case .changed:
                /* User is dragging*/
                
                if newHeight < maxmimumContainerHeight{
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
                else if newHeight < maxmimumContainerHeight && isDraggingDown{      //C3: New height is below max and going down, then animate back to default
                    animateContainerHeight(defaultHeight)
                }
                else if newHeight > defaultHeight && !isDraggingDown {              //C4: New height is below max and going up, set to max height
                    animateContainerHeight(maxmimumContainerHeight)
                }
            default:
                break
            }
    }
    
    /*
        @dimmedViewTapped
        Dismiss the view when the dimmed view is tapped
     */
    @objc func dimmedViewTapped(gesture: UIPanGestureRecognizer){
        self.animateDismissView()
    }

}
