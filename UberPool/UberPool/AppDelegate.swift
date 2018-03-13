//
//  AppDelegate.swift
//  UberPool
//
//  Created by Jeevan on 28/11/17.
//  Copyright © 2017 Jeevan. All rights reserved.
//

import UIKit
import FirebaseCore
import GoogleMaps
import GooglePlaces


@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
     var window: UIWindow?
     let containerViewController = ContainerViewController()
     func application(_ application: UIApplication, didFinishLaunchingWithOptions
        
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        AppConfig.observerChangesInFirebase()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = containerViewController

        window!.makeKeyAndVisible()
        GMSServices.provideAPIKey(AppConfig.sharedInstance.APIKEY)
        GMSPlacesClient.provideAPIKey(AppConfig.sharedInstance.PLACEAPIKEY)
        GMSServices.provideAPIKey(AppConfig.sharedInstance.PLACEAPIKEY)
        
        return true
    }
    
}
