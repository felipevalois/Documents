//
//  DocumentsTableViewController.swift
//  Documents
//
//  Created by Felipe Costa on 6/18/19.
//  Copyright © 2019 Felipe Costa. All rights reserved.
//

import UIKit
import CoreData

class DocumentsTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate{

    var documents = [Document]()
    let dateFormatter = DateFormatter()
    var searchController: UISearchController?
    
    var managedObjectContext: NSManagedObjectContext?{
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Search Documents"

        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController?.searchBar.delegate = self
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchDocuments(searchString: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchString = searchController.searchBar.text {
            fetchDocuments(searchString: searchString)
        }
    }

    func fetchDocuments(searchString: String) {
        managedObjectContext?.perform {
            let request: NSFetchRequest<Document> = Document.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            do{
                if searchString != "" {
                    request.predicate = NSPredicate(format: "name contains[c] %@ OR body contains[c] %@", searchString, searchString)
                }
                self.documents = try self.managedObjectContext!.fetch(request)
                self.tableView.reloadData()
            }
            catch{
                print("Could not fetch documents from Core Data :\(error.localizedDescription)")
            }
        }
    }
    

    
    // MARK: - Table view functions
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
        let tempSize = String(document.size)
        cell.size.text = "Size: " + tempSize + " bytes"
        cell.modified.text = "Modified: " + dateFormatter.string(from: document.modified!)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //DELETE
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
