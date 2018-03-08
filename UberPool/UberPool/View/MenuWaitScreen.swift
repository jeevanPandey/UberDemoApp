//
//  MenuWaitScreen.swift
//  UberPool
//
//  Created by Jeevan on 08/03/18.
//  Copyright © 2018 Jeevan. All rights reserved.
//

import UIKit

class MenuWaitScreen: UIView {

    @IBOutlet var movingObj: UIImageView!

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func awakeFromNib() {

        super.awakeFromNib()
        animateobject()

    }

    func animateobject() {
        
        movingObj.addBounceAnimationToView()
    }
}
