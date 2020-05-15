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
        return price.subtracting(previousPrice)
    }
    
    func priceChangePercentage() -> NSDecimalNumber {
        guard let price = self.price else { return 0 }
        guard let previousPrice = self.previousClose else { return 0 }
        let change = price.subtracting(previousPrice).dividing(by: previousPrice).multiplying(by: 100)
        let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let rounded = change.rounding(accordingToBehavior: handler)
        return rounded
    }
}
