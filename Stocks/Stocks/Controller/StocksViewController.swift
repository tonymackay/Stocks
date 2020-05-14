//
//  StocksViewController.swift
//  Stocks
//
//  Created by Tony Mackay on 14/05/2020.
//  Copyright © 2020 ViewModel Software. All rights reserved.
//

import UIKit
import CoreData

class StocksViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    // MARK: Outlets
    
    // MARK: Variables
    
    let reuseIdentifier = "stockTableViewCell"
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Stock>!
    var watchlist: Watchlist!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(systemName: "plus")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style:.plain, target: self, action: #selector(addTapped))
        
        setupFetchedResultsController()
        
        let stock = Stock(context: dataController.viewContext)
        stock.creationDate = Date()
        stock.companyName = "Tesla Motors Inc"
        stock.symbol = "TSLA"
        stock.exchangeName = "Nasdaq"
        stock.costBasis = 790.96
        stock.watchlist = watchlist
        dataController.saveContext()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    // MARK: UITableView Delegates
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Watchlist: \(watchlist.name ?? "")"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        let stock = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = stock.symbol
        cell.detailTextLabel?.text = stock.companyName
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected row at: \(indexPath.row)")
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let stockToDelete = fetchedResultsController.object(at: indexPath)
            dataController.viewContext.delete(stockToDelete)
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
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        default:
            print("insert or delete not called")
        }
    }
    
    // MARK: Actions
    
    @objc func addTapped() {
        print("Add Stock Tapped")
    }
    
    // MARK: Methods
    
    func setupFetchedResultsController() {
        if fetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Stock> = Stock.fetchRequest()
            let predicate = NSPredicate(format: "watchlist == %@", watchlist)
            fetchRequest.predicate = predicate
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
}
