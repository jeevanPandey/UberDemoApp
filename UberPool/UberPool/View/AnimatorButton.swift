//
//  AnimatorButton.swift
//  UberPool
//
//  Created by Jeevan on 29/11/17.
//  Copyright © 2017 Jeevan. All rights reserved.
//

import UIKit

class AnimatorButton: UIButton {

    var originalSize:CGSize?
     let animator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    override func awakeFromNib() {
        
        setupView()
    }
    
    func setupView() {
    
        originalSize = self.frame.size
        animator.color = UIColor.brown
        animator.hidesWhenStopped = true
        animator.alpha = 0.0
        setupShadow()
    }

   func setupShadow() {

        self.layer.cornerRadius = 30.0
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
        self.layer.shadowRadius = 30.0
    }
    
    func animatedTheButton(shouldAnimate:Bool,title:String?) {

        if shouldAnimate {
        
            UIView.animate(withDuration: 0.5, animations: {
               
                self.setTitle("", for: .normal)
                self.isUserInteractionEnabled = false
                
                self.frame = CGRect(x: (self.superview!.frame.width/2-self.frame.height/2),
                                    y: self.frame.origin.y,
                                    width: self.frame.size.height,
                                    height: self.frame.size.height)
                
               self.layer.cornerRadius = self.frame.size.width/2
               self.animator.center = CGPoint(x: self.frame.size.width/2+1, y:self.frame.size.height/2+1)
                self.addSubview(self.animator)
                
            }, completion: { finished in
                
                if finished {
                
                    UIView.animate(withDuration: 0.2, animations: {
                   
                        self.animator.startAnimating()
                        self.animator.alpha = 1.0
                        
                        
                    })
                }
                
            })
        }
        
        else {

            animator.removeFromSuperview()
            self.setTitle(title, for: .normal)
            UIView.animate(withDuration: 0.2, animations: {
                
                self.frame = CGRect(x: 0, y: 0, width: self.originalSize!.width, height: self.originalSize!.height)
                self.isUserInteractionEnabled = true
            })
           
        }

    }

}
