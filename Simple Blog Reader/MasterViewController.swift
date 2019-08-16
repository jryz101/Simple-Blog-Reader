//  MasterViewController.swift
//  Simple Blog Reader
//  Created by Jerry Tan on 16/08/2019.
//  Copyright © 2019 Starknet Technologies®. All rights reserved.


import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController : DetailViewController?    = nil
    var managedObjectContext : NSManagedObjectContext?  = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //A value that identifies the location of a resource, such as an item on a remote server or the path to a local file | Google Blog API
        let url = URL(string: )!
        //An object that coordinates a group of related network data transfer tasks
        let task = URLSession.shared.dataTask(with: url) {
            
            (data, response, error) in
            //Conditional construction methods for log error
            if error != nil {
                
                print(error!)
                
            } else {
                
                if let urlContent = data {
                    
                    //Do try catch block for processing Json data
                    do {
                        
                        //An object that converts between JSON and the equivalent Foundation objects
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: Any]
                        
                        print(jsonResult)
                        
                        //Cast the jsonResult as NSArray using the Optional Binding methods
                        if let items = jsonResult["items"] as? [[String: Any]] {
                            
                            //The managed object context used to fetch objects
                            let context = self.fetchedResultsController.managedObjectContext
                            
                            //A description of search criteria used to retrieve data from a persistent store.
                            let request = NSFetchRequest<Event>(entityName: "Event")
                            
                            do {
                                //Returns an array of objects that meet the criteria specified by a given fetch request.
                                let results = try context.fetch(request)
                                
                                //Conditional methods to check the results.count is greater than 0
                                if results.count > 0 {
                                    
                                    //For in loop methods for loop through the results and delete the old result data
                                    for result in results {
                                        
                                        context.delete(result)
                                        
                                        //Do try catch construction methods for save the update data
                                        do {
                                            
                                            try context.save()
                                            
                                        } catch {
                                            
                                            print("Specific delete failed")
                                            
                                        }
                                    }
                                }
                                
                            } catch {
                                
                                print("Delete failed")
                                
                            }
                                
                                
                                
                            
                            //Loop through the items object using the for in loop
                            for item in items {
                                
                                print(item["published"]!)
                                
                                print(item["title"]!)
                                
                                print(item["content"]!)
                                
                                let newEvent = Event(context: context)
                                
                                // If appropriate, configure the new managed object.
                                newEvent.timestamp = Date()
                                
                                //Sets the property of the receiver specified by a given key to a given value
                                newEvent.setValue(item["published"] as! String, forKey: "published")
                                newEvent.setValue(item["title"] as! String, forKey: "title")
                                newEvent.setValue(item["content"] as! String, forKey: "content")
                                
                                // Save the context.
                                do {
                                    try context.save()
                                } catch {
                                    // Replace this implementation with code to handle the error appropriately.
                                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                    let nserror = error as NSError
                                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                                }
                                
                            }
                            //DispatchQueue manages the execution of work items. Each work item submitted to a queue is processed on a pool of threads managed by the system
                            DispatchQueue.main.async {
                                
                                //Call reload data
                                self.tableView.reloadData()
                            }
                            
                        }
                        
                    } catch {
                        
                        print("JSON Processing Failed")
                        
                    }
                }
            }
        }
        
        //Newly-initialized tasks begin in a suspended state, so you need to call this method to start the task
        task.resume()
    }
    
    
    
    
    @objc
    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        let newEvent = Event(context: context)
             
        // If appropriate, configure the new managed object.
        newEvent.timestamp = Date()

        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    
    
    
    

    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    
    
    
    
    

    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let event = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withEvent: event)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }


    func configureCell(_ cell: UITableViewCell, withEvent event: Event) {
        cell.textLabel!.text = event.value(forKey: "title") as? String
    }
    
    
    
    
    
    

    // MARK: - Fetched results controller
    var fetchedResultsController: NSFetchedResultsController<Event> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Event>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Event)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Event)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */
}

