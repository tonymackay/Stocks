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
