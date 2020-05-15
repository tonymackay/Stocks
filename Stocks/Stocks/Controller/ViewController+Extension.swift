//
//  ViewController+Extension.swift
//  Stocks
//
//  Created by Tony Mackay on 15/05/2020.
//  Copyright © 2020 ViewModel Software. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}
