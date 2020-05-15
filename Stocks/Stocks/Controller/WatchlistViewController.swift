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
    let segueIdentifier = "toStocksSegue"
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Watchlist>!
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        
        let image = UIImage(systemName: "plus")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style:.plain, target: self, action: #selector(addTapped))
        
        setupFetchedResultsController()
    }
    
    deinit {
        fetchedResultsController = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let watchlist = sender as? Watchlist else { return }
        if let vc = segue.destination as? StocksViewController {
            vc.dataController = dataController
            vc.watchlist = watchlist
        }
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
        showStocksForWatchlist(indexPath: indexPath)
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("insert")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            showStocksForWatchlist(indexPath: newIndexPath!)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        default:
            print("insert or delete not called")
        }
    }
     
    // MARK: Actions
    
    @objc func addTapped() {
        print("Add Watchlist Tapped")
        let alert = UIAlertController(title: "Create Watchlist", message: "", preferredStyle: UIAlertController.Style.alert)
        
        var textField: UITextField?
        alert.addTextField { (nameTextField) in
            textField = nameTextField
            textField?.placeholder = "Enter name"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (UIAlertAction)in
             print("User clicked Close button")
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (UIAlertAction)in
             print("User click OK button")
            
            guard let name = textField?.text else { return }
            
            let watchlist = Watchlist(context: self.dataController.viewContext)
            watchlist.creationDate = Date()
            watchlist.name = name
            self.dataController.saveContext()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Methods
    
    func setupFetchedResultsController() {
        if fetchedResultsController == nil {
            print("setupFetchedResultsController")
            let fetchRequest: NSFetchRequest<Watchlist> = Watchlist.fetchRequest()
            let sortByDate: NSSortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            fetchRequest.sortDescriptors = [sortByDate]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
        }
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func showStocksForWatchlist(indexPath: IndexPath) {
        let watchlist = fetchedResultsController.object(at: indexPath)
        performSegue(withIdentifier: segueIdentifier, sender: watchlist)
    }
}
