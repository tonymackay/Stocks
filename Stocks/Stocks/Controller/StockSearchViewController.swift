//
//  StockSearchViewController.swift
//  Stocks
//
//  Created by Tony Mackay on 15/05/2020.
//  Copyright © 2020 ViewModel Software. All rights reserved.
//

import UIKit

class StockSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var noResultsView: UIView!
    
    // MARK: Variables
    
    let reuseIdentifier = "stockSearchTableViewCell"
    var dataController: DataController!
    var watchlist: Watchlist!
    var stocks = [StockDTO]()
    var searchTask: DispatchWorkItem?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.becomeFirstResponder()
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton{
            cancelButton.isEnabled = true
        }
    }
    
    // MARK: UITableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stocks.count == 0 {
            tableView.backgroundView = noResultsView
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
        
        return stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        let stock = stocks[indexPath.row]
        
        cell.textLabel?.text = stock.symbol
        cell.detailTextLabel?.text = stock.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stock = stocks[indexPath.row]

        let newStock = Stock(context: dataController.viewContext)
        newStock.creationDate = Date()
        newStock.companyName = stock.description
        newStock.symbol = stock.symbol
        newStock.watchlist = watchlist
        
        newStock.quote { (error) in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                self.dataController.saveContext()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: UISearchBar Delegates
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTask?.cancel()
    
        if searchText == "" {
            stocks.removeAll()
            tableView.reloadData()
            return
        }
    
        // Replace previous task with a new one
        let task = DispatchWorkItem { [weak self] in
            self?.search(searchText: searchText)
        }
        searchTask = task

        // Execute task in 0.75 seconds (if not cancelled !)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75, execute: task)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Actions
    
    // MARK: Methods
    
    func search(searchText: String) {
        StocksClient.search(query: searchText) { (stocks, error) in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            self.stocks = stocks
            self.tableView.reloadData()
        }
    }
}
