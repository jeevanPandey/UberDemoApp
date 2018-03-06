//
//  Alertable.swift
//  UberPool
//
//  Created by Jeevan on 27/12/17.
//  Copyright © 2017 Jeevan. All rights reserved.
//

import UIKit

protocol Alertable {}

extension Alertable where Self : UIViewController {
    
   func showAlert(_ message:String) {
        let alertVC = UIAlertController(title: "Error Has Occurred:", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(alertAction)
        self.present(alertVC, animated: true, completion: nil)
    }
}

