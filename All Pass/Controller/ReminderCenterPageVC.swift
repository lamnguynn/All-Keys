//
//  NotificationCenterPageVC.swift
//  All Pass
//
//  Created by Lam Nguyen on 7/5/21.
//

import UIKit
import CoreData

class ReminderCenterPageVC: UIViewController {
    
    
    // MARK: view life cycle
    let table = UITableView()
    let headerLabel = UILabel()
    lazy var bellImageView = UIImageView()
    lazy var nothingLabel = UILabel()
    var notificationsList = [ReminderEntry]()
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        //Load all the notification from core data and clear any that have expired
        let fetchRequest: NSFetchRequest<ReminderEntry> = ReminderEntry.fetchRequest()
        do{
            let notif =  try PersistenceManager.context.fetch(fetchRequest)
            notificationsList = notif
        }catch{
            //Catch error. Later on send an email to developer about any issue
            print("error: failed to load data")
        }
        clearOldNotifications()
        
        // Set up the header label
        view.addSubview(headerLabel)
        headerLabel.attributedText = NSAttributedString(string: "Reminders", attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 36),
            NSAttributedString.Key.foregroundColor: UIColor(red: 32/255, green: 118/255, blue: 128/255, alpha: 1)
        ])
        headerLabel.adjustsFontSizeToFitWidth = true
        
        addLabelConstraints()
        
        // Set up the table
        view.addSubview(table)
        table.delegate = self
        table.dataSource = self
        table.register(ReminderCenterTableCell.self, forCellReuseIdentifier: "datacell")
        table.keyboardDismissMode = .onDrag
        table.backgroundColor = .white
        table.tableFooterView = UIView()
        addTableConstraints()
        
        // Set up items when table is empty
        configureEmptyItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if notificationsList.isEmpty{
            showEmptyNotificationItems()
        }
        else{
            hideEmptyNotificationItems()
        }
    }
    
    // MARK: asset supporting functions
    
    /*
        @configureEmptyItems
        Create the empty notification items to show if the notification page is empty
     */
    func configureEmptyItems(){
        //Create the label and image
        nothingLabel.text = "Nothing here yet..."
        nothingLabel.textColor = .gray
        nothingLabel.adjustsFontSizeToFitWidth = true
        nothingLabel.minimumScaleFactor = 0.5
        
        let image = UIImage(systemName: "bell")
        bellImageView = UIImageView(image: image)
        bellImageView.tintColor = .gray

        //Add to view and apply constraints
        table.addSubview(bellImageView)
        table.addSubview(nothingLabel)
        
        bellImageView.translatesAutoresizingMaskIntoConstraints = false
        bellImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        bellImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        bellImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        bellImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        bellImageView.alpha = 0.15
        
        nothingLabel.translatesAutoresizingMaskIntoConstraints = false
        nothingLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        nothingLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        nothingLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        nothingLabel.topAnchor.constraint(equalTo: bellImageView.topAnchor, constant: 100).isActive = true
        nothingLabel.alpha = 0.3
    }
    
    /*
     Hide the empty notification items
     */
    private func showEmptyNotificationItems(){
        nothingLabel.isHidden = false
        bellImageView.isHidden = false
    }
    
    /*
     Show the empty notification items
     */
    private func hideEmptyNotificationItems(){
        nothingLabel.isHidden = true
        bellImageView.isHidden = true
    }
    
    // MARK: asset constraints
    
    /*
        @addTableConstraints
        Adds constraints to the table in this scene
     */
    func addTableConstraints() {
        table.translatesAutoresizingMaskIntoConstraints = false
        table.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 14).isActive = true
        table.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        table.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        table.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    /*
        @addLabelConstraints
        Adds constraints to the header label
     */
    func addLabelConstraints(){
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width - 12).isActive = true
        headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height / 6.49 - 10).isActive = true
        headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14).isActive = true
    }
    
    // MARK: helper functions
    
    /*
        @clearOldNotifications
        Clears all old notifications from core data to clear up space
     */
    func clearOldNotifications(){
        var index = 0
        var dayComponent = DateComponents()
        dayComponent.day = 3
        let calendar = Calendar.current
        
        for entry in notificationsList{
            let threeDaysLaterFromDeadline = calendar.date(byAdding: dayComponent, to: entry.date!)
            //Remove any old reminders after three days
            if threeDaysLaterFromDeadline! < Date(){
                //Delete from core data
                PersistenceManager.context.delete(entry)
                PersistenceManager.saveContext()
                
                //Delete from model and update the index value to be correct
                notificationsList.remove(at: index)
                continue
            }
            index += 1
        }
    }

}

// MARK: table functions 
extension ReminderCenterPageVC: UITableViewDelegate, UITableViewDataSource, MoreInfoDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Customize the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "datacell", for: indexPath) as! ReminderCenterTableCell
        cell.backgroundColor = .white
        cell.selectionStyle = .none
        cell.delegate = self
        
        //Customize the title label
        let titleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                          NSAttributedString.Key.foregroundColor: UIColor.black]
        let titleText = notificationsList[indexPath.row].title
        cell.titleLabel.attributedText = NSAttributedString(string: titleText!, attributes: titleAttributes)
        cell.titleLabel.font = UIFont(name: "NotoSans-Regular", size: 16)

        //Customize the date label
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY, hh:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        let dateString = dateFormatter.string(from: notificationsList[indexPath.row].date!)
        let datettributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12),
                          NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        cell.infoLabel.attributedText = NSAttributedString(string: dateString, attributes: datettributes)
        
        //Change text to red when date has passed
        if notificationsList[indexPath.row].date! < Date(){
            cell.infoLabel.textColor = .red
        }
        
        //Add action to the more info button
        cell.moreInfoButton.addTarget(self, action: #selector(moreInfoClicked), for: .touchUpInside)
        
        return cell
    }
    
    /*
        @heightForRowAt
        Returns the height of a cell
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    /*
        @trailingSwipeActionsConfigurationForRowAt
        Delete a notification upon swipe left
     */
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //Build the action
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { action, view, success in
            //Delete from view
            DispatchQueue.main.async {
                self.table.deleteRows(at: [indexPath], with: .fade)
                if self.notificationsList.isEmpty{
                    self.showEmptyNotificationItems()
                }
            }
            
            //Delete from core data
            let deleteEntry = self.notificationsList[indexPath.row]
            PersistenceManager.context.delete(deleteEntry)
            PersistenceManager.saveContext()
            
            //Delete from model
            self.notificationsList.remove(at: indexPath.row)
            
            success(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        //Return the action
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }
    
    func moreClicked(cell: ReminderCenterTableCell) {
        indexPath = table.indexPath(for: cell)
    }
    
    // MARK: objc functions
    
    @objc func moreInfoClicked(){
        let vc = ViewReminderPageVC()
        vc.modalPresentationStyle = .overCurrentContext
        vc.reminderDetails = notificationsList[indexPath!.row]
        vc.reminderCenter = self
        
        self.present(vc, animated: false)
    }
}
