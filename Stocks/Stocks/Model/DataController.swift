//
//  DataController.swift
//  Stocks
//
//  Created by Tony Mackay on 13/05/2020.
//  Copyright © 2020 ViewModel Software. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func quote(stocks: [Stock], completion: ((Error?) -> Void)? = nil) {
        let symbols = stocks.map { $0.symbol ?? "" }
        
        StocksClient.quote(symbol: symbols) { quote, error in
            if let error = error {
                print(error.localizedDescription)
                completion?(error)
                return
            }
            
            for dto in quote {
                let stock = stocks.filter { $0.symbol == dto.symbol }
                if stock.count == 1 {
                    stock[0].currency = dto.currency
                    stock[0].previousClose = NSDecimalNumber(decimal: dto.previousPrice)
                    stock[0].price = NSDecimalNumber(decimal: dto.price)
                }
            }
            completion?(nil)
        }
    }
}


