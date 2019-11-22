//
//  UploadViewController.swift
//  Rexpiry
//
//  Created by Simon Wei on 2019-06-23.
//  Copyright © 2019 Simon Wei. All rights reserved.
//

import UIKit
import TesseractOCR


class UploadViewController: UIViewController, G8TesseractDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var pickerController = UIImagePickerController()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerController.delegate = self
        loading.isHidden = true
 
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
        }
        pickerController.dismiss(animated: true, completion: nil)
    }
        
    @IBAction func galleryButton(_ sender: Any) {
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }

    
    
    @IBAction func uploadButton(_ sender: Any) {
        DispatchQueue.main.async{
            self.loading.isHidden = false
            self.loading.startAnimating()
        }
        guard let picture = imageView.image else { return}
        let string = process(image: picture)
        let lines = string.components(separatedBy: "\n")
        for line in lines {
            let words = line.components(separatedBy: " ")
            for word in words {
                let days = retrieveData(word: word)
                if days != -1 {
                    if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                        let newItem = RexpiryCoreData(context: context)
                        newItem.name = word
                        newItem.daysLeft = String(days)
                        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
                    }
                }
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func process(image: UIImage) -> String {
        var string = ""
        if let tesseract = G8Tesseract(language: "eng") {
            tesseract.delegate = self
            tesseract.image = image
            tesseract.recognize()
            string = tesseract.recognizedText!
            print(string)
        }
        return string
    }

    
    func retrieveData(word: String) -> Int {
        let queryItem = [NSURLQueryItem(name: "Product", value: word)]
        let urlComps = NSURLComponents(string:
            //17438f79.ngrok.io
            "http://172.20.10.3/FoodExpiryWeb/api/createfood.php")!
        urlComps.queryItems = queryItem as [URLQueryItem]
        let url = urlComps.url!
        var result = 0
        
        let semaphore = DispatchSemaphore(value: 0)
        
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
                                result = expiryDays
                                semaphore.signal()
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
        semaphore.wait()
        return result
    }
    
}
