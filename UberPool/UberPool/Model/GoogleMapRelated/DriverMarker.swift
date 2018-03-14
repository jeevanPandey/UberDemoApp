//
//  DriverMarker.swift
//  UberPool
//
//  Created by Jeevan on 14/03/18.
//  Copyright © 2018 Jeevan. All rights reserved.
//


import CoreLocation

import UIKit
import GoogleMaps

class DriverMarker: GMSMarker {
    var key:String = ""
    init(coordinate:CLLocationCoordinate2D,with annKey:String) {
         super.init()
        key = annKey
        position = coordinate
        title = "Driver is Here"
        icon = #imageLiteral(resourceName: "driverAnnotation")
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = .pop
    }
}
