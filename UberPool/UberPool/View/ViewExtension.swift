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

}
