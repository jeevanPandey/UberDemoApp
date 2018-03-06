//
//  LocationServices.swift
//  UberPool
//
//  Created by Jeevan on 06/12/17.
//  Copyright © 2017 Jeevan. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation
import MapKit

class LocationService {
    
    static var instance = LocationService()
    
    func observerLocationValueForDriver(withCoordinate coordinate:CLLocationCoordinate2D)  {
        
        DataService.instace.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snaps = snapshot.children.allObjects as? [DataSnapshot] {
                
                for eachSnap in snaps {
                    if eachSnap.key == Auth.auth().currentUser?.uid {
                   
                        if let isEnabled:Bool =  eachSnap.childSnapshot(forPath: "isPickUpModeEnabled").value as? Bool,isEnabled == true {
                            DataService.instace.REF_DRIVERS.child(Auth.auth().currentUser!.uid).updateChildValues(["coordinate":[coordinate.latitude,coordinate.longitude]])
                           
                        }
                    }
                   
                }
            }
            
        }) { (error) in
            
            print("error ")
        }
        
    }
    func observerLocationValueForUser(withCoordinate coordinate:CLLocationCoordinate2D)  {
        
        DataService.instace.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snaps = snapshot.children.allObjects as? [DataSnapshot] {
                
                for eachSnap in snaps {
                    if eachSnap.key == Auth.auth().currentUser?.uid {
                        
                        DataService.instace.REF_USERS.child(Auth.auth().currentUser!.uid).updateChildValues(["coordinate":[coordinate.latitude,coordinate.longitude]])
                    }
                    
                }
            }
            
        }) { (error) in
            
            print("error ")
        }
        
    }
   
    
    func queryDriversLocation(mapView:MKMapView, completion: @escaping (_ result: [DriverAnnotation])->Void)
    {
        
        var allAnn:[DriverAnnotation] = []
        
        for case let driverAnn as DriverAnnotation in mapView.annotations {
            allAnn.append(driverAnn)
        }
        var allAnnotaions:[DriverAnnotation] = []
        
        DataService.instace.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snaps = snapshot.children.allObjects as? [DataSnapshot] {
                
                for eachSnap in snaps {
                    
                    if let isEnabled:Bool =  eachSnap.childSnapshot(forPath: "isPickUpModeEnabled").value as? Bool,isEnabled == true, let eachDict = eachSnap.childSnapshot(forPath: "coordinate").value as? NSArray  {
                        
                        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: eachDict[0] as! CLLocationDegrees, longitude: eachDict[1] as! CLLocationDegrees)
                        
                        
                        if let annoation = allAnn.first(where: { $0.key == eachSnap.key  }) {

                           if (eachSnap.childSnapshot(forPath: "isDriverOnTrip").value as? Bool == false) {

                                 annoation.upadateAnnotaion(annotaionPostion: annoation, withCoordinate: coordinate)
                            }

                        }
                        
                        else {
                            let driverAnn:DriverAnnotation = DriverAnnotation(coordinate: coordinate, with: eachSnap.key)
                            allAnnotaions.append(driverAnn)
                        }
                    }
                }
               completion(allAnnotaions)
            }
            
        }) { (error) in
            
            print("error ")
        }
    }
    
    func updateTripsOnRequest() {
        
        DataService.instace.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snaps = snapshot.children.allObjects as? [DataSnapshot] {
                
                for eachSnap in snaps {
                    if eachSnap.key == Auth.auth().currentUser?.uid {

                        let eachDictCordinate = eachSnap.childSnapshot(forPath: "coordinate").value as? NSArray
                        let eachDictTripCordinate = eachSnap.childSnapshot(forPath: "tripCoordinate").value as? NSArray
                        
                      /*  DataService.instace.REF_USERS.child(Auth.auth().currentUser!.uid).updateChildValues(["coordinate":[coordinate.latitude,coordinate.longitude]]) */
                        DataService.instace.REF_TRIPS.child(Auth.auth().currentUser!.uid).updateChildValues(["initialCordinate":[eachDictCordinate],
                                                                                                             "destinationCoordinate":[eachDictTripCordinate],
                                                                                                             "pessangerKey":Auth.auth().currentUser!.uid,
                                                                                                             "tripIsAccepted":false
                                                                                                             ])
                        
                    }
                    
                }
            }
            
        }) { (error) in
            
            print("error ")
        }
        
    }
    
    func observeTrips(handler:@escaping (_ iscancelled:Bool,_ responseDict:Dictionary<String,AnyObject>?)-> Void ) {
        

        DataService.instace.REF_TRIPS.observe(.value, with: { snaps in

            if(!snaps.exists()) {
                handler(true, nil)
    
            }
            if let snaps = snaps.children.allObjects as? [DataSnapshot] {
                
                for eachSnap in snaps {

                    if (eachSnap.hasChild("pessangerKey") && eachSnap.hasChild("destinationCoordinate")) {
                        
                        if let tripDict = eachSnap.value as? Dictionary<String,AnyObject> {
                            handler(false,tripDict)
                            
                        }
                    }
                    
                }
            }
           
        })

    }

    func resetDriverData(driverKey:String) {

         DataService.instace.REF_DRIVERS.child(driverKey).updateChildValues(["isDriverOnTrip":false])
    }
    
    func upadateTripCordinate(withCoordinate coordinate:CLLocationCoordinate2D) {
        
        DataService.instace.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snaps = snapshot.children.allObjects as? [DataSnapshot] {
                
                for eachSnap in snaps {
                    if eachSnap.key == Auth.auth().currentUser?.uid {
                        
                        DataService.instace.REF_USERS.child(Auth.auth().currentUser!.uid).updateChildValues(["tripCoordinate":[coordinate.latitude,coordinate.longitude]])
                    }
                    
                }
            }
            
        }) { (error) in
            
            print("error ")
        }
    }
    
    func acceptTrip(passenger pasengerKey:String,ForDriver driverKey:String) {
        
        DataService.instace.REF_TRIPS.child(pasengerKey).updateChildValues(["driverKey": driverKey,"tripIsAccepted":true])
        DataService.instace.REF_DRIVERS.child(driverKey).updateChildValues(["isDriverOnTrip":true])
        
    }
    
    func cancelTrip(passenger pasengerKey:String,ForDriver driverKey:String) {
         DataService.instace.REF_DRIVERS.child(driverKey).updateChildValues(["isDriverOnTrip":false])
        cancelTripForPassanger(passenger: pasengerKey)
       

    }
    
    func cancelTripForPassanger(passenger pasengerKey:String) {
         DataService.instace.REF_TRIPS.child(pasengerKey).removeValue()
         DataService.instace.REF_USERS.child(pasengerKey).child("destinationCoordinate").removeValue()
         DataService.instace.REF_USERS.child(pasengerKey).child("tripCoordinate").removeValue()
        
    }
    
    func observereUpcomTrips(_ forPessangerKey:String, handler:@escaping(_ isUserHasCancelled:Bool,_ driverId:String?)->Void) {
        
        DataService.instace.REF_TRIPS.child(forPessangerKey).observe(.value, with: {(dataSnap) in
            
            if (!dataSnap.exists()) {
                handler(true,nil)
                return
            }
            
            if let status = dataSnap.childSnapshot(forPath: "tripIsAccepted").value as? Bool,let driverKey = dataSnap.childSnapshot(forPath: "driverKey").value as? String,status == true {
                handler(false, driverKey)
                return
            }
            
        })
    }

    func saveLocationTripOnFB(locationCoordinate:CLLocationCoordinate2D,forUserId userId:String) {
        
         DataService.instace.REF_USERS.child(userId).updateChildValues(["tripCoordinate":[locationCoordinate.latitude,locationCoordinate.longitude]])
    }
}
    



