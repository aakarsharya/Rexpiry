//
//  CompleteViewController.swift
//  Rexpiry
//
//  Created by Simon Wei on 2019-06-22.
//  Copyright © 2019 Simon Wei. All rights reserved.
//

import UIKit

class CompleteViewController: UIViewController {
    var item : RexpiryCoreData? = nil
    
    @IBAction func DeleteButton(_ sender: Any) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            if let item = item {
                context.delete(item)
            }
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        }
        // Pop back
        navigationController?.popViewController(animated: true)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }


}
