//
//  RexpiryTableViewController.swift
//  Rexpiry
//
//  Created by Simon Wei on 2019-06-22.
//  Copyright © 2019 Simon Wei. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class RexpiryTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var items = [RexpiryCoreData]()
    var item : RexpiryCoreData? = nil
    var pickerController = UIImagePickerController()
    
    override func viewWillAppear(_ animated: Bool) {
        getItems()
        timeUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerController.delegate = self
        
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Food Expiring!"
        content.body = "Check the expiry dates"
        
        /*let date = Date().addingTimeInterval(15)
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true) */
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        // Tuesday
        dateComponents.hour = 8   // 14:00 hours
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: true)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        //dateComponents.calendar = Calendar.current
        //dateComponents.hour = 8    // 14:00 hours
        center.add(request){ (error) in
            
        }
        // Create the trigger as a repeating event.
        
    }
    
    func getItems() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let itemsFromCoreData = try? context.fetch(RexpiryCoreData.fetchRequest()) {
                if let tempItems = itemsFromCoreData as? [RexpiryCoreData] {
                    items = tempItems
                    tableView.reloadData()
                }
            }
        }
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return items.count
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let currentItem = items[indexPath.row]
        var cellText1 = ""
        var cellText2 = ""
        if let nameText = currentItem.name {
            cellText1 = nameText + ": "
        }
        if let daysText = currentItem.daysLeft {
            cellText2 = daysText + " Days Left"
        }
        cell.textLabel?.text = cellText1 + cellText2

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                let item = items[indexPath.row]
                context.delete(item)
                (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
                getItems()
            }
        }
    }
    
    var prevTime = "0" // change this to todays date on presentation
    
    func timeUpdate() {
        let time = DateFormatter.localizedString(from: Date(), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.none)
        if time != prevTime {
            for item in items {
                if Int(item.daysLeft!)! > 1 {
                    item.daysLeft = String(Int(item.daysLeft!)! - 1)
                } else {
                    item.daysLeft = "0"
                }
            }
            prevTime = time
            tableView.reloadData()
        } else {
            tableView.reloadData()
            return
        }
    }
    
}
