//
//  ViewExtension.swift
//  UberPool
//
//  Created by Jeevan on 01/12/17.
//  Copyright © 2017 Jeevan. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    //MARK: - Help
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.window)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboardHeight = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.frame.origin.y = -1 * keyboardHeight!
            self.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.frame.origin.y = 0
            self.layoutIfNeeded()
        })
    }
    
    func resignTextFieldFirstResponders() {
        for textField in self.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
    }
    
    func resignAllFirstResponders() {
        self.endEditing(true)
    }

    private func setupViewForTimer(_ beginTime: Double) {

        let layer = CAShapeLayer()
        layer.fillColor = UIColor(red: 84/255, green: 122/255, blue: 183/255, alpha: 1.0).cgColor
        layer.strokeColor = UIColor.clear.cgColor
        let center = CGPoint(x: self.bounds.midX, y:self.bounds.midY)
        let startPath = UIBezierPath(arcCenter: center, radius: 2,
                                     startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)

        let endPath = UIBezierPath(arcCenter: center, radius: 50,
                                   startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
        layer.path = startPath.cgPath
        self.layer.insertSublayer(layer, at: 0)

        let animation = CABasicAnimation(keyPath: "path")
        animation.timingFunction =  CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

        animation.fromValue = startPath.cgPath
        animation.toValue = endPath.cgPath

        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 0.8
        fadeAnimation.toValue = 0.0

        let animationGroup = CAAnimationGroup()
        animationGroup.beginTime = beginTime
        animationGroup.animations = [animation, fadeAnimation]
        animationGroup.duration = 5
        animationGroup.repeatCount = Float.infinity
        layer.add(animationGroup, forKey: nil)
    }

    func animateAnnotationView() {
        setupViewForTimer(0)
        setupViewForTimer(2)
        setupViewForTimer(3)
    }


    func rotationAnnotationView() {

        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveLinear, animations: {
            self.transform = self.transform.rotated(by: CGFloat(Double.pi))
        }) { finished in
            self.rotationAnnotationView()
            // self.rotateView(view: targetView, duration: 1.0)
        }
    }

    func addBounceAnimationToView()
    {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale") as CAKeyframeAnimation
        bounceAnimation.values = [ 0.05, 1.1, 0.9, 1]
        let timingFunctions = NSMutableArray(capacity: bounceAnimation.values!.count)
        for _ in bounceAnimation.values! {
            timingFunctions.add(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        }
        bounceAnimation.timingFunctions = timingFunctions as NSArray as? [CAMediaTimingFunction]
        bounceAnimation.isRemovedOnCompletion = false
        self.layer.add(bounceAnimation, forKey: "bounce")
    }


}
