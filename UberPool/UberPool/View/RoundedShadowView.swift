//
//  RoundedShadowView.swift
//  UberPool
//
//  Created by Jeevan on 28/11/17.
//  Copyright © 2017 Jeevan. All rights reserved.
//

import UIKit

class RoundedShadowView: UIImageView {

    override func awakeFromNib() {
        
        self.setupView()
    }
    func setupView() {
        
        self.layer.cornerRadius = 5.0
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        self.layer.shadowRadius = 5.0
    }

}
