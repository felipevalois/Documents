//
//  DocumentsTableViewController.swift
//  Documents
//
//  Created by Felipe Costa on 6/18/19.
//  Copyright © 2019 Felipe Costa. All rights reserved.
//

import UIKit
import CoreData

class DocumentsTableViewController: UITableViewController{
    
    var documents = [Document]()
    let dateFormatter = DateFormatter()
    
    
    var managedObjectContext: NSManagedObjectContext?{
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveDocuments()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        retrieveDocuments()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentsTableViewCell", for: indexPath) as! DocumentsTableViewCell
        
        let document: Document = documents[indexPath.row]
        cell.title.text = document.name
        cell.size.text = "Size: " + String(document.size)
        cell.modified.text = "Modified: " + dateFormatter.string(from: document.modified!)
        print("\(document.modified!) from tableviewcontroller")
        cell.backgroundColor = UIColor.clear

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
 
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//        tableView.reloadData()
//    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "DELETE") { (action, indexPath) in
            
            let document = self.documents[indexPath.row]
            context.delete(document)
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do {
                self.documents = try context.fetch(Document.fetchRequest())
            }
            catch {
                print("Failed to delete note.")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
        return [delete]
    }
 
    
    
    func retrieveDocuments(){
        managedObjectContext?.perform {
            self.fetchDocsFromCoreData{ (documents) in
                if let documents = documents {
                    self.documents = documents
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func fetchDocsFromCoreData(completion: @escaping([Document]?) -> Void){
        managedObjectContext?.perform {
            var documents = [Document]()
            let request: NSFetchRequest<Document> = Document.fetchRequest()
            
            do{
                documents = try self.managedObjectContext!.fetch(request)
                completion(documents)
            }
            catch{
                print("Could not fetch documents from Core Data :\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let textAreaViewController = segue.destination as! TextAreaViewController
                let selectedDoc: Document = documents[indexPath.row]
                
                textAreaViewController.indexPath = indexPath.row
                textAreaViewController.isExisting = false
                textAreaViewController.document = selectedDoc
            }
            
        }
            
        else if segue.identifier == "addItem" {
            
        }
    }
    
    
}
