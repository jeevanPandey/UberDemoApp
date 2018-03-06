//
//  GTXVC.swift
//  UberPool
//
//  Created by Jeevan on 30/11/17.
//  Copyright © 2017 Jeevan. All rights reserved.
//

import UIKit

class GTXVC: UIViewController {
    @IBOutlet var mylabel: UILabel!
    
    @IBOutlet var tittleLabel: UILabel!
    var tagValue:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        mylabel.text = "Tag value:\(tagValue)"
    
    }
    
    @IBAction func dismissMe(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   
}
