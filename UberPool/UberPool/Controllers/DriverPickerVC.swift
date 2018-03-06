//
//  DriverPickerVC.swift
//  UberPool
//
//  Created by Jeevan on 02/01/18.
//  Copyright © 2018 Jeevan. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class DriverPickerVC: UIViewController {

    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var imageMap: RoundedImageView!
    
    @IBOutlet var acceptTripButton: UIButton!
    @IBOutlet var tripRequestLabel: UILabel!
    
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var wouldLikeLabel: UILabel!
    var imageForMap:UIImage?
    var upcomingPassengerID:String?
    var driverLocation:CLLocation?
    var isTripAcceptted = false
    override func viewDidLoad() {
        
        super.viewDidLoad()
        resetUI()
        SharedLocationManager.instance.checkForAutherization { (status, location) in
            
            if(status) {
                print("location will come")
                self.driverLocation = location
                if self.isTripAcceptted
                {
                    self.navigateUserToMapLoc()

                }
            }
            else {
                print("has been denied!")
            }
        }
        self.mapView.delegate = self
        self.lookForAnyRideRequest()

    }

    func resetUI()  {
        self.isTripAcceptted = false
        self.upcomingPassengerID = nil
        self.acceptTripButton.isHidden = true
        self.wouldLikeLabel.isHidden = true
        self.tripRequestLabel.isHidden = false
        self.cancelBtn.isHidden = true
        self.imageMap.isHidden = true
        self.mapView.isHidden = true
        self.imageMap.image = nil
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.removeOverlays(self.mapView.overlays)
    }

    func showMapOnScreen()  {

        self.acceptTripButton.isHidden = true
        self.wouldLikeLabel.isHidden = true
        self.tripRequestLabel.isHidden = false
        self.cancelBtn.isHidden = false
        self.imageMap.isHidden = true
        self.mapView.isHidden = false
        self.imageMap.image = nil

    }

    func lookForAnyRideRequest() {

        LocationService.instance.observeTrips { (isCancelled, dictionary) in

            if(isCancelled){
                LocationService.instance.resetDriverData(driverKey: Auth.auth().currentUser!.uid)
                self.resetUI()
            }
            else {
                if let dictResp =  dictionary,let currentUserId = Auth.auth().currentUser?.uid  {
                    DataService.instace.driverIsAvailable(key: currentUserId, handler: { (isAvailable) in

                        if(isAvailable == true) {
                            print("available he is ")
                            self.addPinToMap(responseDict: dictResp)
                        }
                        else {

                            print("dictionary is \(dictResp)")
                            if let tripIsAccepted = dictResp["tripIsAccepted"] as? Bool,let driverKey = dictResp["driverKey"] as? String {
                                if(tripIsAccepted && driverKey == currentUserId) {
                                    self.cancelBtn.isHidden = false
                                    print("congratulation on your Trip!")
                                    self.isTripAcceptted = tripIsAccepted
                                   // self.navigateUserToMapLoc()
                                }
                                else {
                                    self.isTripAcceptted = false
                                    print("Better luck next time...")
                                }
                            }
                        }
                    })
                }
            }
        }
    }

    func navigateUserToMapLoc() {

        let region = MKCoordinateRegionMakeWithDistance(self.driverLocation!.coordinate, 500, 500)
        //MKCoordinateRegion(center: userLocation.coordinate, span: span)
        self.mapView.setRegion(region, animated: true)

    }
    

    func addPinToMap(responseDict:Dictionary<String,AnyObject>) {
        
        upcomingPassengerID = responseDict["pessangerKey"] as? String
        setupPinDireactionForPassenger(passngerId: upcomingPassengerID!)

       /*
        let initialCoordinateArray = responseDict["initialCordinate"] as? NSArray
        let initialCoordinate = initialCoordinateArray?.firstObject as? NSArray

        let intialAnnotaion = MKPointAnnotation()
        let coordinateDriver = CLLocationCoordinate2D(latitude: initialCoordinate![0] as! CLLocationDegrees, longitude: initialCoordinate![1] as! CLLocationDegrees)
        intialAnnotaion.coordinate = coordinateDriver
        let sourceAnnotation = DriverAnnotation(coordinate: coordinateDriver, with: Auth.auth().currentUser!.uid)

        let destinationCoordinateArray = responseDict["destinationCoordinate"] as? NSArray
        let destinationCoordinate = destinationCoordinateArray?.firstObject as? NSArray
        let destinationAnnotaion = MKPointAnnotation()
        let coordinateUser = CLLocationCoordinate2D(latitude: destinationCoordinate![0] as! CLLocationDegrees, longitude: destinationCoordinate![1] as! CLLocationDegrees)
        destinationAnnotaion.coordinate = coordinateUser
        let desinationAnn = UserAnnotation(coordinate: coordinateUser, with: upcomingPassengerID!)
        self.mapView.addAnnotations([sourceAnnotation,desinationAnn])
      //  self.mapView.addAnnotations([intialAnnotaion,destinationAnnotaion])
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)

        let sourceMapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinateDriver))
        let destinationMapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinateUser))
        self.mapView.setupDirection(sourceMapItem: sourceMapItem, destinationMapItem: destinationMapItem)
        self.activateUpcomingTripState()

            */
    }

    func setupPinDireactionForPassenger(passngerId:String){

        DataService.instace.REF_USERS.child(passngerId).observeSingleEvent(of: .value, with: { (snapShot) in

            let coordinateArray = snapShot.childSnapshot(forPath: "coordinate").value as! NSArray
            let destinationCoordinate = CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
            let destinationAnn = DestinationAnnotation(coordinate: destinationCoordinate, with: passngerId)

            let sourceAnn = DriverAnnotation(coordinate: self.driverLocation!.coordinate, with: AppConfig.sharedInstance.userID!)
            self.mapView.addAnnotations([destinationAnn,sourceAnn])
            self.mapView.showAnnotations([destinationAnn,sourceAnn], animated: true)

            let sourceMapItem = MKMapItem(placemark: MKPlacemark(coordinate: self.driverLocation!.coordinate))
            let destinationMapItem = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
            self.mapView.setupDirection(sourceMapItem: sourceMapItem, destinationMapItem: destinationMapItem)
            self.activateUpcomingTripState()

        })

    }



    func activateUpcomingTripState() {

        self.mapView.getImageForRenderAnnotaion { (imageForTrip) in

            guard let image = imageForTrip else {
                return
            }
            self.acceptTripButton.isHidden = false
            self.wouldLikeLabel.isHidden = true
            self.tripRequestLabel.isHidden = true
            self.imageMap.isHidden = false
            self.view.bringSubview(toFront: self.imageMap)
            self.imageMap.image = image
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let image = self.imageForMap {
            self.imageMap.image = image
        }
    }


    @IBAction func closeThisController(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func acceptTripTap(_ sender: Any) {
        if let passengerKey = self.upcomingPassengerID,let driverID = Auth.auth().currentUser?.uid {
            LocationService.instance.acceptTrip(passenger: passengerKey, ForDriver: driverID)
            self.showMapOnScreen()
        }
        
    }
    
    @IBAction func cancelRidePressed(_ sender: Any) {


        if let passengerKey = self.upcomingPassengerID,let driverID = Auth.auth().currentUser?.uid {
            LocationService.instance.cancelTrip(passenger: passengerKey, ForDriver: driverID)
            self.resetUI()

        }
        
    }
}


extension DriverPickerVC:MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        LocationService.instance.observerLocationValueForDriver(withCoordinate: userLocation.coordinate)
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        // getCoordinateForDrivers()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is DriverAnnotation) {
            
            var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "driverAnnoation")
            if annotationView == nil{
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "driverAnnoation")
                annotationView?.canShowCallout = false
            }else{
                annotationView?.annotation = annotation
            }
            annotationView?.image = #imageLiteral(resourceName: "driverAnnotation")
            
            return annotationView
            
        }
            
        else if (annotation is UserAnnotation) {
            
            var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "userAnnoation")
            if annotationView == nil{
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userAnnoation")
                annotationView?.canShowCallout = false
            }else{
                annotationView?.annotation = annotation
            }
            annotationView?.image = #imageLiteral(resourceName: "currentLocationAnnotation")
            
            return annotationView
            
        }
            
        else if (annotation is DestinationAnnotation) {
            
            var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "destination")
            if annotationView == nil{
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "destination")
                annotationView?.canShowCallout = false
            }else{
                annotationView?.annotation = annotation
            }
            annotationView?.image = #imageLiteral(resourceName: "destinationAnnotation")
            
            return annotationView
            
        }
        
        return nil
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.lineWidth = 4.0
        renderer.lineDashPhase = 0.5
        renderer.strokeColor = UIColor.blue
        renderer.miterLimit = 5.0
        return renderer
    }
    
}

