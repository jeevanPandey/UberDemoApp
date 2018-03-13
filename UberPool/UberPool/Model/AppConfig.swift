//
//  AppConfig.swift
//  UberPool
//
//  Created by Jeevan on 05/01/18.
//  Copyright © 2018 Jeevan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

final class AppConfig {
    static let sharedInstance = AppConfig()
    var isDriver:Bool = false
    var isPickModeEnabled = false
    var userEmail:String?
    var userID:String?
    let APIKEY =  "AIzaSyCxegjFsilwL5KMu1z7U2FoclIsG_HgZcw"
    let PLACEAPIKEY = "AIzaSyA861JSogN0t1aG1DBdnE8Gr68k4WLAfHI"
    let DIRECTIONKEY = "AIzaSyCvj7QA5lF0DPJzByvzm-oMZORbYsa7cxI"
    
    private init() {}
    
    static func observerChangesInFirebase() {

        guard let currentUserID =  Auth.auth().currentUser?.uid else {
            
            return
        }
        
        self.sharedInstance.userID = currentUserID
        observereFireBaseChnagesForDriver()
        observereFireBaseChnagesForPassenger()
    }
    
    
   static func observereFireBaseChnagesForPassenger() {
        
        DataService.instace.REF_USERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snaps = snapshot.children.allObjects as? [DataSnapshot] {
                
                for eachSnap in snaps {
                    
                    if eachSnap.key == Auth.auth().currentUser?.uid {
                    self.sharedInstance.isDriver = false
                    self.sharedInstance.userEmail = Auth.auth().currentUser?.email
                    self.sharedInstance.isPickModeEnabled = false
                     
                    }
                }
            }
            
        }) { (error) in
            
            print("error ")
        }
    }
    
  static  func observereFireBaseChnagesForDriver() {
        
        DataService.instace.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snaps = snapshot.children.allObjects as? [DataSnapshot] {
                
                for eachSnap in snaps {
                    
                    if eachSnap.key == Auth.auth().currentUser?.uid {
                        
                        self.sharedInstance.isDriver = true
                        self.sharedInstance.userEmail = Auth.auth().currentUser?.email
                        let isPickOn:Bool = eachSnap.childSnapshot(forPath: "isPickUpModeEnabled").value as! Bool
                        self.sharedInstance.isPickModeEnabled = isPickOn

                    }
                }
            }
            
        }) { (error) in
            
            print("error ")
        }
    }
    
    static func configureForUserType(authUser:User,isDriver:Bool) {
        
        AppConfig.sharedInstance.userID = authUser.uid
        AppConfig.sharedInstance.isDriver = isDriver
        AppConfig.sharedInstance.isPickModeEnabled = false
        AppConfig.sharedInstance.userEmail = authUser.email
        
    }
}

