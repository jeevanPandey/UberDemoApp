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
import GoogleMaps
import GooglePlaces

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

    @IBOutlet var googleMap: GMSMapView!
    let dataProvider = GoogleDataProvider()
    let searchRadius: Double = 1000
    var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]

    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?

    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialViewSetup()
        checkLocationAuthorizationStatus()
       // self.updatePathsAndAnnotations()
       // centerMapOnLocation(location: initialLocation)
        destinationText.delegate = self
        startPointText.delegate = self
        googleMap.delegate = self
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
        destinationText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
       // self.setupSearchView()
    }

    func setupSearchView() {

        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController

      //  let subView = UIView(frame: CGRect(x: 0, y: view.bounds.midY, width: view.bounds.width, height: 45.0))

       // subView.addSubview((searchController?.searchBar)!)
       // self.view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        self.present(searchController!, animated: true, completion: nil)
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
         googleMap.camera = GMSCameraPosition(target: userLocation.coordinate, zoom: 15,
                                            bearing: 0, viewingAngle: 0)
        // fetchNearbyPlaces(coordinate: userLocation.coordinate)

      /*
        if(self.isTripAcceptted){
            var span = MKCoordinateSpan()
            span.latitudeDelta = 0.05
            span.longitudeDelta = 0.05
            let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 500, 500)
            //MKCoordinateRegion(center: userLocation.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
        } */
    }
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            googleMap.isMyLocationEnabled = true
            googleMap.settings.myLocationButton = true


        } else {
            locationManager.requestWhenInUseAuthorization()
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

    func didSelectPredictionItem(item: GMSAutocompletePrediction) {

        print("items is \(item)")

        removeCustomView { (isComplted) in
            if(isComplted) {

               self.setupGoogleOvelays(item: item)
                
            }
        }
    }

    func setupGoogleOvelays(item:GMSAutocompletePrediction){
        let client =  GMSPlacesClient()
        client.lookUpPlaceID(item.placeID!) { (fetchPlace, error) in

            if(error == nil) {
                print("place is \(fetchPlace)")
              /*  self.getPolylineRoute(from:self.locationManager.location!.coordinate,
                                 to:fetchPlace!.coordinate ) */

                self.setupPolylines(origin: self.locationManager.location!.coordinate, destination: fetchPlace!.coordinate)

            }
            else {
                print("error \(error) ")
            }
        }
    }

    func setupPolylines(origin:CLLocationCoordinate2D,destination:CLLocationCoordinate2D) {

        googleMap.clear()
        dataProvider.getPolylineRoute(source: origin, destination: destination) { (pathString) in
            self.addMarkers(originRoute: origin, destinationCoordinate: destination)
            self.showPath(polyStr: pathString!)
            let bounds = GMSCoordinateBounds(coordinate: origin, coordinate: destination)
            let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(170, 30, 30, 30))
            self.googleMap!.moveCamera(update)
        }

       /* dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
            places.forEach {
                let marker = PlaceMarker(place: $0)
                marker.map = self.googleMap

            }
            self.locationManager.stopUpdatingLocation()
        }*/
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

     func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
        googleMap.clear()
        dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
            places.forEach {
                let marker = PlaceMarker(place: $0)
                marker.map = self.googleMap

            }
            self.locationManager.stopUpdatingLocation()
        }
    }

    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let key = AppConfig.sharedInstance.DIRECTIONKEY

        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=true&mode=driving&key=\(key)")!

        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                        guard let routes = json["routes"] as? NSArray else {
                            return
                        }

                        if (routes.count > 0) {
                            let overview_polyline = routes[0] as? NSDictionary
                            let dictPolyline = overview_polyline?["overview_polyline"] as? NSDictionary

                            let points = dictPolyline?.object(forKey: "points") as? String

                            DispatchQueue.main.async {
                                self.addMarkers(originRoute: source, destinationCoordinate: destination)
                                self.showPath(polyStr: points!)
                                let bounds = GMSCoordinateBounds(coordinate: source, coordinate: destination)
                                let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(170, 30, 30, 30))
                                self.googleMap!.moveCamera(update)
                            }
                        }
                    }
                }
                catch {
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }

    func showPath(polyStr :String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5.0
        polyline.strokeColor = UIColor.blue
        polyline.map = googleMap

    }

    func addMarkers(originRoute:CLLocationCoordinate2D,destinationCoordinate:CLLocationCoordinate2D) {

        let markerorgin = GMSMarker(position: originRoute)
        markerorgin.map = self.googleMap
        markerorgin.icon = GMSMarker.markerImage(with: UIColor.purple)
        let markerDest = GMSMarker(position: destinationCoordinate)
        markerDest.map = self.googleMap
        markerDest.icon = GMSMarker.markerImage(with: UIColor.red)

    }

}

extension HomeVC: GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
       // reverseGeocodeCoordinate(position.target)
    }

    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
       /* addressLabel.lock()

        if (gesture) {
            mapCenterPinImage.fadeIn(0.25)
            mapView.selectedMarker = nil
        } */
    }

    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let placeMarker = marker as? PlaceMarker else {
            return nil
        }
        guard let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView else {
            return nil
        }

        infoView.nameLabel.text = placeMarker.place.name
         infoView.placePhoto.image = #imageLiteral(resourceName: "driverAnnotation")
       /* if let photo = placeMarker.place.photo {
            infoView.placePhoto.image = photo
        } else {
            infoView.placePhoto.image = UIImage(named: "generic")
        } */

        return infoView
    }
/*
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapCenterPinImage.fadeOut(0.25)
        return false
    }

    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapCenterPinImage.fadeIn(0.25)
        mapView.selectedMarker = nil
        return false
    } */

}

