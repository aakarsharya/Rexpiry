//
//  manualItemViewController.swift
//  Rexpiry
//
//  Created by Simon Wei on 2019-06-22.
//  Copyright © 2019 Simon Wei. All rights reserved.
//

import UIKit
import Foundation

class manualItemViewController: UIViewController{

    @IBOutlet weak var nameTextfield: UITextField!

    @IBOutlet weak var daysTextfield: UITextField!
    
    
    var RexpiryTableVC : RexpiryTableViewController? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    @IBAction func AddButton(_ sender: Any) {
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let newItem = RexpiryCoreData(context: context)
            if let name = nameTextfield.text {
                newItem.name = name
            }
            if let days = daysTextfield.text {
                newItem.daysLeft = days
            }
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        }
        
        navigationController?.popViewController(animated: true)
    }

    
    @IBAction func expiry(_ sender: Any) {
        let queryItem = [NSURLQueryItem(name: "Product", value: nameTextfield.text)]
        let urlComps = NSURLComponents(string: "http://172.20.10.3/FoodExpiryWeb/api/createfood.php")!
        urlComps.queryItems = queryItem as [URLQueryItem]
        let url = urlComps.url!
        
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error ?? "Something went wrong")
                return
            } else {
                if let urlContent = data {
                    
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Int]
                        
                        if let jsonDic = jsonResult{
                            if let expiryDays = jsonDic["message"]{
                               DispatchQueue.main.async {
                                if expiryDays == -1{
                                    self.daysTextfield.text = "Item not in database"
                                }
                                else{
                                self.daysTextfield.text = String(expiryDays)
                                }
                                }
                                // send expiryDays to expiry value in string
                            }
                        }
                        
                    } catch {
                        print("JSON Processing Failed")
                        
                    }
                }
            }
        }
        task.resume()
    }
    
}
