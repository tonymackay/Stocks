//
//  WatchlistViewController.swift
//  Stocks
//
//  Created by Tony Mackay on 12/05/2020.
//  Copyright © 2020 ViewModel Software. All rights reserved.
//

import UIKit
import CoreData

class WatchlistViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: Outlets
    
    // MARK: Variables
    
    let reuseIdentifier = "watchlistTableViewCell"
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Watchlist>!
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFetchedResultsController()
        
        // TEMP DATA
        let new = Watchlist(context: dataController.viewContext)
        new.creationDate = Date()
        new.name = "Index Funds"
        
        dataController.saveContext()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    // MARK: UITableView Delegates
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        let watchlist = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = watchlist.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected row at: \(indexPath.row)")
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let watchlistToDelete = fetchedResultsController.object(at: indexPath)
            dataController.viewContext.delete(watchlistToDelete)
            dataController.saveContext()
        default:
            print("not implemented")
        }
    }
    
    // MARK: NSFetchedResultsControllerDelegate Delegates
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        
        switch type {
        case .insert:
            tableView.insertRows(at: [indexPath], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath], with: .fade)
        default:
            print("not implemented")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
     
    // MARK: Actions
    
    // MARK: Methods
    
    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Watchlist> = Watchlist.fetchRequest()
        let sortByDate: NSSortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortByDate]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
}
