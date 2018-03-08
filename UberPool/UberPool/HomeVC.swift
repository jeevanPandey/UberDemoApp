//
//  ViewController.swift
//  UberPool
//
//  Created by Jeevan on 28/11/17.
//  Copyright © 2017 Jeevan. All rights reserved.
//

import UIKit
import MapKit
import RevealingSplashView
import Firebase


class HomeVC: UIViewController {

    @IBOutlet var rideButton: AnimatorButton!
    @IBOutlet var fareEstimateButton: AnimatorButton!
    @IBOutlet var rideCancelBtn: UIButton!
    @IBOutlet var mapView: MKMapView!
    var leftViewController: SidePanelViewController?
    var revealeview :RevealingSplashView?
    let locationManager = CLLocationManager()
    var delegate: HomeViewControllerDelegate?
    let regionRadius: CLLocationDistance = 1000
    let initialLocation = CLLocation(latitude: 37.330509259999999, longitude: -122.03060348)
    
    @IBOutlet var ButtonView: UIView!
    @IBOutlet var startPointText: UITextField!
    @IBOutlet var destinationText: UITextField!
    var customView : LocationSearchTable!
    var anchor:NSLayoutConstraint!
    var appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var isTripAcceptted = false
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialViewSetup()
        checkLocationAuthorizationStatus()
        self.updatePathsAndAnnotations()
        centerMapOnLocation(location: initialLocation)
        destinationText.delegate = self
        startPointText.delegate = self
    }
    

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)

    }

    func initialViewSetup() {
        
        mapView.delegate = self
        locationManager.delegate = self
        revealeview = RevealingSplashView(iconImage: UIImage(named: "launchScreenIcon")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: UIColor.white)
        view.addSubview(revealeview!)
        revealeview?.animationType = .twitter
        revealeview?.startAnimation()
        revealeview?.heartAttack = true
        self.rideCancelBtn.isHidden = true
        self.ButtonView.isHidden = true
        self.startPointText.isUserInteractionEnabled = false
    }
    
    func getCoordinateForDrivers() {
        if isTripAcceptted {return}

        DataService.instace.REF_DRIVERS.observe(.value, with: { snaps in
            
           self.setupAnnoations()
        })
    }
    
    func setupAnnoations() {

        var allAnn:[DriverAnnotation] = []
        
        for case let driverAnn as DriverAnnotation in self.mapView.annotations {
            allAnn.append(driverAnn)
        }
        LocationService.instance.queryDriversLocation(mapView: self.mapView) { (snaps) in
            
            for eachSnap in snaps {
                
                 self.mapView.addAnnotation(eachSnap)
            }

        }
    }
    
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    @IBAction func menuBtnPressed(_ sender: Any) {
        
       delegate?.toggleLeftPanel?()
    }

    @IBAction func rideButtonPressed(_ sender: Any) {
        rideButton.animatedTheButton(shouldAnimate: true, title: nil)
        LocationService.instance.updateTripsOnRequest()
        self.rideCancelBtn.isHidden = false
        self.fareEstimateButton.isUserInteractionEnabled = false
        self.rideButton.isUserInteractionEnabled = false

    }
    
    @IBAction func cancelTheRide(_ sender: Any) {

        isTripAcceptted = false
        LocationService.instance.cancelTripForPassanger(passenger: AppConfig.sharedInstance.userID!)
        rideCancelBtn.isHidden  = true
        centerMapOnLocation(location: SharedLocationManager.instance.upadateLocation)
        removeOverlaysAnnotations()
       // self.removeDrwanAnnotations()
        setupAnnoations()
        rideButton.animatedTheButton(shouldAnimate: false, title: "REQUEST A RIDE")
        self.fareEstimateButton.isUserInteractionEnabled = true
        self.rideButton.isUserInteractionEnabled = true
    }

    @IBAction func centerToTheLocation(_ sender: Any) {
         centerMapOnLocation(location: SharedLocationManager.instance.upadateLocation)
    }

    func removeOverlaysAnnotations() {
        centerMapOnLocation(location: SharedLocationManager.instance.upadateLocation)
        mapView.removeOverlays(mapView.overlays)
        for  eachAnn in mapView.annotations {

            if eachAnn is UserAnnotation || eachAnn is DestinationAnnotation {

                mapView.removeAnnotation(eachAnn)
            }
        }
    }

    func removeDrwanAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
    }

    func updatePathsAndAnnotations() {
        DataService.instace.REF_TRIPS.child(AppConfig.sharedInstance.userID!).observe(.value, with: {(dataSnap) in

            if (!dataSnap.exists()) {
                self.rideCancelBtn.isHidden  = true
                self.centerMapOnLocation(location: SharedLocationManager.instance.upadateLocation)
                self.rideButton.animatedTheButton(shouldAnimate: false, title: "REQUEST A RIDE")
                self.removeDrwanAnnotations()
                self.setupAnnoations()
                self.isTripAcceptted = false
            }
            else {
                if  dataSnap.childSnapshot(forPath: "tripIsAccepted").value as? Bool == true  {
                     self.removeDrwanAnnotations()
                    self.isTripAcceptted = true
                    self.mapView.connectuserAndDriverForTripSnap(dataSnap: dataSnap)
                }
            }
        })
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        destinationText.resignFirstResponder()
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let collapsed = appDelegate.containerViewController.currentState
            if collapsed != .bothCollapsed {

                delegate?.toggleLeftPanel?()
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        

    }
}

extension HomeVC:CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let location = locations.last! as CLLocation
        let userLocation:CLLocation = locations[0] as CLLocation
        if(self.isTripAcceptted){
            var span = MKCoordinateSpan()
            span.latitudeDelta = 0.05
            span.longitudeDelta = 0.05
            let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 500, 500)
            //MKCoordinateRegion(center: userLocation.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }
}

extension HomeVC:LocationSearchTableDelegate {
    
    func diSelectItem(item:MKMapItem) {
        
        removeCustomView { (isComplted) in
            if(isComplted) {
                self.setupUserLocation(mapitem: item)
            }
        }
    }

    func removeCustomView(completionHandler:@escaping (Bool) -> ())  {

        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {

            self.anchor.constant = self.view.frame.size.height-10
            self.view.layoutIfNeeded()

        }) { (isComplete) in
            self.customView.removeFromSuperview()
            self.customView = nil
            self.ButtonView.isHidden = false
             completionHandler(isComplete)
        }
    }

    func removeDestinationAnnotation() {

        for eachAnn in self.mapView.annotations {
            if eachAnn is DestinationAnnotation {
                self.mapView.removeAnnotation(eachAnn)
            }
        }
    }
    
    func setupUserLocation(mapitem:MKMapItem) {
        
        self.destinationText.text = mapitem.name
        let tripCordinate = mapitem.placemark.coordinate

        if  let curreLocation = locationManager.location,let userId = Auth.auth().currentUser?.uid {

            self.removeDestinationAnnotation()
            LocationService.instance.saveLocationTripOnFB(locationCoordinate: tripCordinate, forUserId: userId)

            let userAnnoation = UserAnnotation(coordinate: curreLocation.coordinate, with:userId)
            let destinationAnn = DestinationAnnotation(coordinate: tripCordinate, with: userId)
            self.mapView.addAnnotations([userAnnoation,destinationAnn])
            self.mapView.layoutMargins = UIEdgeInsets(top: 90, left: 10, bottom: 90, right: 10)
            self.mapView.showAnnotations([userAnnoation,destinationAnn], animated: true)
            let sourceMapItem:MKMapItem = MKMapItem.forCurrentLocation()
            self.mapView.setupDirection(sourceMapItem: sourceMapItem, destinationMapItem: mapitem)
            
        }
    }

}

