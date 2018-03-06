//
//  RoundedImageView.swift
//  UberPool
//
//  Created by Jeevan on 01/12/17.
//  Copyright © 2017 Jeevan. All rights reserved.
//

import UIKit

class RoundedImageView: UIImageView {

    override func awakeFromNib() {
         setupRoundedView()
    }
    
    func setupRoundedView() {
    
        self.layer.cornerRadius = self.frame.width/2
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        
        self.layer.borderWidth = 1.5
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 3.0
        self.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        
        
        
    }

}
