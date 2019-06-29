//
//  TextAreaViewController.swift
//  Documents
//
//  Created by Felipe Costa on 6/17/19.
//  Copyright © 2019 Felipe Costa. All rights reserved.
//

import UIKit
import CoreData

class TextAreaViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    
    @IBOutlet weak var titleName: UITextField!
    @IBOutlet weak var textArea: UITextView!
 
    var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    var document: Document?
    var isExisting = false
    var indexPath: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load data
        if let document = document {
            titleName.text = document.name
            textArea.text = document.body
        }
        if titleName.text != "" {
            isExisting = true
        }
        
        titleName.delegate = self
        textArea.delegate = self
        self.title = titleName.text

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func SetTitleName(_ sender: Any) {
        self.title = titleName.text
    }
    
    @IBAction func SaveDocument(_ sender: UIBarButtonItem) {
        if titleName.text == "" || textArea.text == "" {
            let alertController = UIAlertController(title: "Missing Information", message: "You left one or more fields empty. Please make sure all fields have been filled before attempting to save", preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            if(!isExisting){
                let docName = titleName.text
                let docBody = textArea.text
            
                if let moc = managedObjectContext {
                    let document = Document(context: moc)
                    document.name = docName
                    document.body = docBody
                    document.size = Int64(textArea.text.count)
                    document.modified = Date()
            
                    saveToCoreData(){
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            else if (isExisting){
                let document = self.document
            
                let managedObject = document
                managedObject!.setValue(titleName.text, forKey: "name")
                managedObject!.setValue(textArea.text, forKey: "body")
                managedObject!.setValue(Int64(textArea.text.count), forKey: "size")
                managedObject!.setValue(Date(), forKey: "modified")
            
            
                do{
                    try context.save()
                    saveToCoreData(){
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                catch{
                    print("Failed to update existing note")
                }
            }
        }
    }
    
    //CoreData helper function
    func saveToCoreData(completion: @escaping() -> Void){
        managedObjectContext!.perform{
            do{
                try self.managedObjectContext?.save()
                completion()
                print("Doc saved to core data")
            }
            catch let error {
                print("Could not save doc to CoreData: \(error.localizedDescription)")
            }
        }
    }
 
}


