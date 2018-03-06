//
//  SharedLocationManager.swift
//  UberPool
//
//  Created by Jeevan on 15/01/18.
//  Copyright © 2018 Jeevan. All rights reserved.
//

import Foundation
import CoreLocation

class SharedLocationManager:CLLocationManager {
    
    static var instance = SharedLocationManager()
    let initialLocation = CLLocation(latitude: 37.330509259999999, longitude: -122.03060348)
    var upadateLocation = CLLocation(latitude: 37.330509259999999, longitude: -122.03060348)
    var sharedHandler =  { (isAuthrized:Bool,location:CLLocation?) -> (Void) in } //(isAuthrized:Bool,location:CLLocation)->Void
    
    func checkForAutherization(handler:@escaping(_ isAuthrized:Bool,_ location:CLLocation?)->Void)  {

        SharedLocationManager.instance.delegate = self

        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.sharedHandler = handler
            SharedLocationManager.instance.startUpdatingLocation()
        }
        else {
        
            SharedLocationManager.instance.requestWhenInUseAuthorization()

        }
        
    }
}

extension SharedLocationManager:CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        let userLocation:CLLocation = locations[0] as CLLocation
        SharedLocationManager.instance.upadateLocation = userLocation
        sharedHandler(true, userLocation)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if (status == .authorizedWhenInUse) {
            
            SharedLocationManager.instance.delegate = self
            SharedLocationManager.instance.startUpdatingLocation()
        } else {
            
             sharedHandler(false, nil)
        }
        
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

        sharedHandler(false,nil)
    }
}
