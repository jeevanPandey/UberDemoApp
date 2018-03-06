//
//  HomeVCTextExtension.swift
//  UberPool
//
//  Created by Jeevan on 06/03/18.
//  Copyright © 2018 Jeevan. All rights reserved.
//

import Foundation
import UIKit

extension HomeVC:UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(!textField.text!.isEmpty){
           self.ButtonView.isHidden = false
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if(!textField.text!.isEmpty){
            addSearchView()
            customView.updateSearchResultsForSearchController(diestinationText: destinationText)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        destinationText.resignFirstResponder()
        startPointText.resignFirstResponder()
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        removeOverlaysAnnotations()
        self.ButtonView.isHidden = true
        return  true
    }

    func addSearchView() {
        removeOverlaysAnnotations()

        if let _ = self.customView {
            return
        }
        self.customView = self.loadViewFromNib()
        self.customView.delegate = self
        self.customView.mapView = self.mapView
        customView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customView)
        customView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        customView.widthAnchor.constraint(equalToConstant: view.frame.size.width-40).isActive = true
        customView.heightAnchor.constraint(equalToConstant: self.view.frame.size.height-200).isActive = true
        anchor =  customView.topAnchor.constraint(equalTo:topLayoutGuide.bottomAnchor, constant: self.view.frame.size.height-10)
        anchor.isActive = true
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            self.anchor.constant = 180
            self.view.layoutIfNeeded()

        }) { (iscompleted) in

        }
    }

    func loadViewFromNib() -> LocationSearchTable {

        let bundle = Bundle.main
        let nib = UINib(nibName: "LocationSearchTable", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! LocationSearchTable
        return view
    }

}
