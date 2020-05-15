//
//  StocksViewController.swift
//  Stocks
//
//  Created by Tony Mackay on 14/05/2020.
//  Copyright © 2020 ViewModel Software. All rights reserved.
//

import UIKit
import CoreData

class StockTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    
}

class StocksViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    // MARK: Outlets
    
    // MARK: Variables
    
    let reuseIdentifier = "stockTableViewCell"
    let segueIdentifier = "toStockSearchSegue"
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Stock>!
    var watchlist: Watchlist!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(systemName: "plus")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style:.plain, target: self, action: #selector(addTapped))
        
        let image2 = UIImage(systemName: "arrow.2.circlepath.circle.fill")
        navigationItem.rightBarButtonItems?.append(UIBarButtonItem(image: image2, style:.plain, target: self, action: #selector(refreshTapped)))
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        setupFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getQuotes()
    }
    
    deinit {
        fetchedResultsController = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let watchlist = sender as? Watchlist else { return }
        if let vc = segue.destination as? StockSearchViewController {
            vc.dataController = dataController
            vc.watchlist = watchlist
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! StockTableViewCell
        
        let stock = fetchedResultsController.object(at: indexPath)
                
        cell.symbolLabel?.text = stock.symbol
        cell.companyNameLabel?.text = stock.companyName
        cell.priceLabel.text = stock.priceString()
        cell.priceChangeLabel.text = stock.priceChangeString()
        
        if stock.priceChangePercentage().decimalValue.isSignMinus {
            cell.priceChangeLabel.textColor = UIColor.systemRed
        } else {
            cell.priceChangeLabel.textColor = UIColor.systemGreen
        }
        
        return cell
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        default:
            print("insert, delete or update not called")
        }
    }
    
    // MARK: Actions
    
    @objc func addTapped() {
        print("Add Stock Tapped")
        performSegue(withIdentifier: segueIdentifier, sender: watchlist)
    }
    
    @objc func refreshTapped() {
        print("Refresh Tapped")
        getQuotes()
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
    
    func getQuotes() {
        self.tableView.footerView(forSection: 1)?.detailTextLabel?.text = "Test"
        if let stocks = fetchedResultsController.fetchedObjects {
            for stock in stocks {
                stock.quote() { (error) in
                    if let error = error {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                        self.tableView.footerView(forSection: 1)?.detailTextLabel?.text = error.localizedDescription
                    }
                }
            }
            dataController.saveContext()
        }
    }
}
