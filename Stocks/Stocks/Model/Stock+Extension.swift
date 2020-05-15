//
//  Stock+Extension.swift
//  Stocks
//
//  Created by Tony Mackay on 15/05/2020.
//  Copyright © 2020 ViewModel Software. All rights reserved.
//

import Foundation

extension Stock {
    func priceChange() -> NSDecimalNumber {
        guard let price = self.price else { return 0 }
        guard let previousPrice = self.previousClose else { return 0 }
        let diff = price.subtracting(previousPrice)

        let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let rounded = diff.rounding(accordingToBehavior: handler)
        return rounded
    }
    
    func priceChangePercentage() -> NSDecimalNumber {
        guard let price = self.price else { return 0 }
        guard let previousPrice = self.previousClose else { return 0 }
        
        if price == 0 || previousPrice == 0 {
            return 0
        }
        
        let change = price.subtracting(previousPrice).dividing(by: previousPrice).multiplying(by: 100)
        let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let rounded = change.rounding(accordingToBehavior: handler)
        return rounded
    }
    
    func priceString() -> String {
        guard let price = self.price else { return "" }
        if price == 0 {
            return ""
        }
        
        let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let rounded = price.rounding(accordingToBehavior: handler)
        return "\(self.currencySymbol ?? "")\(rounded)"
    }
    
    func priceChangeString() -> String {
        let change = priceChange()
        let changePercentage = priceChangePercentage()
        
        if price == 0 || previousClose == 0 {
            return ""
        }
        
        return "\(currencySymbol ?? "")\(change) (\(changePercentage)%)"
    }
    
    func quote(completion: (() -> Void)? = nil) {
        guard let symbol = self.symbol else { return }
        StocksClient.quote(symbol: symbol) { quote, error in
            if let error = error {
                print(error.localizedDescription)
                completion?()
                return
            }

            guard let quote = quote else { return }
            self.exchangeName = quote.price.exchangeName
            self.currency = quote.price.currency
            self.currencySymbol = quote.price.currencySymbol
            self.previousClose = NSDecimalNumber(decimal: quote.price.regularMarketPreviousClose)
            self.price = NSDecimalNumber(decimal: quote.price.regularMarketPrice)
            
            completion?()
        }
    }
}
