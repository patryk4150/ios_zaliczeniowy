//
//  MasterViewController.swift
//  zaliczenie
//
//  Created by kprzystalski on 25/12/2019.
//  Copyright © 2019 kprzystalski. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil

    var appDelegate: AppDelegate? = nil
    
    static var posts: [String] = []
    
    var productsEntity: NSEntityDescription? = nil
        
    let serverUrl: String = "https://d28c471d.ngrok.io" // @TODO: url https z ngrok

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem


        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        self.managedObjectContext = appDelegate?.persistentContainer.viewContext
            
        self.productsEntity = NSEntityDescription.entity(forEntityName: "Product", in: self.managedObjectContext!)
        parseJson()
    }


    func parseJson() {
        let url = URL(string: serverUrl)
        let request = URLRequest(url: url!)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            guard error == nil else {
                print("Nie działa")
                return
            }
            print(response as Any)
            
            guard data != nil else {
                print("Nie ma danych")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                if let object = json as? [String:Any] {
                    print(object)
                } else if let object = json as? [Any] {
                    for element in object as! [Dictionary<String,AnyObject>] {
                        let id = element["id"] as! Int
                        let descrip = element["description"] as! String
                        let image = element["image"] as! String
                        let location_lat = 50
                        let location_long = 50

                      //  let location_lat = element["location_lat"] as! Double
                   //     let location_long = element["location_long"] as! Double
                        let product = element["product"] as! String
                        
                        let post = NSManagedObject(entity: self.productsEntity!, insertInto: self.managedObjectContext)
                        post.setValue(product, forKey: "product")
                        post.setValue(id, forKey: "id")
                        post.setValue(descrip, forKey: "descrip")
                        post.setValue(image, forKey: "image")
                        post.setValue(location_lat, forKey: "location_lat")
                        post.setValue(location_long, forKey: "location_long")
                        print("Added \(product) with id: \(id)")
                        MasterViewController.posts.append(product)
//ZAPYTAĆ O 84 LINIJKE
                    }
                    try self.managedObjectContext?.save()
                } else {
                    print("JSON jest wadliwy")
                }
            } catch {
                print("to nie jest JSON albo nie możemy zserializować JSONa")
            }
            
        })
        task.resume()
    }
    
    
        
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
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
                detailViewController = controller
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
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withEvent product: Product) {
        // @TODO: wypełnij opis komórki Cell tytułem produktu
        
        cell.textLabel!.text = product.product
        
        
//NIE JESTEM TEGO PEWNY
        
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Product> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
                
        fetchRequest.fetchBatchSize = 20
        
        /* @TODO uzupełnij klucz po którym będzie sorotowane*/
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Product>? = nil

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
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Product)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Product)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            default:
                return
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}
