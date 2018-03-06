//
//  DataService.swift
//  UberPool
//
//  Created by Jeevan on 04/12/17.
//  Copyright © 2017 Jeevan. All rights reserved.
//


import Foundation
import Firebase


let DB_BASE = Database.database().reference()

class DataService {
    
    static let instace = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_DRIVERS = DB_BASE.child("drivers")
    private var _REF_TRIPS = DB_BASE.child("trips")
    
    var REF_BASE : DatabaseReference {
    
        return _REF_BASE
    }
    
    var REF_USERS : DatabaseReference {
        
        return _REF_USERS
    }
    
    var REF_TRIPS : DatabaseReference {
        
        return _REF_TRIPS
    }
    
    var REF_DRIVERS : DatabaseReference {
        
        return _REF_DRIVERS
    }
    
    func createFirebaseDBUser(uid:String,userData:Dictionary<String,Any>,isDriver:Bool) {
    
        if isDriver {
        
            REF_DRIVERS.child(uid).updateChildValues(userData)
        }
        else {
        
            REF_USERS.child(uid).updateChildValues(userData)
        }
        
    }
    
    func driverIsAvailable(key:String,handler:@escaping(_ status:Bool)->Void ) {
     
        DataService.instace.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snaps = snapshot.children.allObjects as? [DataSnapshot] {
                
                for eachSnap in snaps {
                    if eachSnap.key == key {
                        
                        if let isEnabled:Bool =  eachSnap.childSnapshot(forPath: "isPickUpModeEnabled").value as? Bool,isEnabled == true,let status = eachSnap.childSnapshot(forPath: "isDriverOnTrip").value as? Bool{
                          
                           handler(!status)
                            break
                            
                        }
                    }
                }
            }
            
        }) { (error) in
            
            print("error ")
        }
    }
    
    func checkPassengerType(handler:@escaping(_ snapShot:DataSnapshot,_ isdriver:Bool)->Void) {
        
       
        DataService.instace.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snaps = snapshot.children.allObjects as? [DataSnapshot] {
                
                for eachSnap in snaps {
                    
                    if eachSnap.key == Auth.auth().currentUser?.uid {
                        
                        let isPickOn:Bool = eachSnap.childSnapshot(forPath: "isPickUpModeEnabled").value as! Bool
                        
                        handler(eachSnap, true)
                        
                    }
                }
            }
            
        }) { (error) in
            
            print("error ")
        }
        
        DataService.instace.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snaps = snapshot.children.allObjects as? [DataSnapshot] {
                
                for eachSnap in snaps {
                    
                    if eachSnap.key == Auth.auth().currentUser?.uid {
                        
                        handler(eachSnap, false)
                        return
                        
    
                        
                    }
                }
            }
            
        }) { (error) in
            
            print("error ")
        }
        
    }
    
    func isDriverOnTrip(driverKey:String,handler:@escaping(_ status:Bool,_ passangerKey:String?,_ tripKey:String?)->Void) {
        
        DataService.instace._REF_DRIVERS.child(driverKey).child("isDriverOnTrip").observe(.value, with: {dataSnapShot in
            
            let driverIsonTrip = dataSnapShot.value as? Bool
           
            if(driverIsonTrip == true ) {
            
                DataService.instace.REF_TRIPS.observeSingleEvent(of: .value, with: {snapshot in
                    
                    if let tripSnaps = snapshot.children.allObjects as? [DataSnapshot] {
                        
                        for eachTrip in tripSnaps {
                            if (eachTrip.childSnapshot(forPath: "driverKey").value as? String == driverKey) {
                                handler(true, eachTrip.key, eachTrip.key)
                                return
                            }
                        }
                       
                        handler(false, nil, nil)
                       
                    }
                })
            }
            
            
        })
        
    }
    
    func isPassangerOnTrip(passengerKey:String,handler:@escaping(_ status:Bool?,_ driverKey:String?,_ tripKey:String?)->Void) {
        
        DataService.instace.REF_TRIPS.observeSingleEvent(of: .value, with: {sanps in
            
            if let tripSnaps = sanps.children.allObjects as? [DataSnapshot] {
             
                for eachTripSnap in tripSnaps {
                    if (eachTripSnap.key == passengerKey && (eachTripSnap.childSnapshot(forPath: "tripIsAccepted").value as? Bool) == true  ) {
                        
                        handler(true, eachTripSnap.childSnapshot(forPath: "driverKey").value as? String, passengerKey)
                        return
                    }
                }
                handler(false, nil, nil)
                
            }
            
            
        })
        
    }
    
}
