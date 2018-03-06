//
//  UserAnnotation.swift
//  UberPool
//
//  Created by Jeevan on 21/12/17.
//  Copyright © 2017 Jeevan. All rights reserved.
//

import Foundation

//
//  DriverAnnotation.swift
//  UberPool
//
//  Created by Jeevan on 07/12/17.
//  Copyright © 2017 Jeevan. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class UserAnnotation: NSObject, MKAnnotation {
    
    var key:String
    dynamic var coordinate:CLLocationCoordinate2D
    
    init(coordinate:CLLocationCoordinate2D,with key:String) {
        
        self.coordinate = coordinate
        self.key = key
        
        super.init()
        
    }
    
    func upadateAnnotaion(annotaionPostion annoation:UserAnnotation,withCoordinate newCoordinate:CLLocationCoordinate2D) {
        
        UIView.animate(withDuration: 0.2) {
            var loc = annoation.coordinate
            loc.latitude = newCoordinate.latitude
            loc.longitude = newCoordinate.longitude
            annoation.coordinate = loc
        }
    }
}
