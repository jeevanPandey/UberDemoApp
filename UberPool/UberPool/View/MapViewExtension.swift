//
//  MapViewExtension.swift
//  UberPool
//
//  Created by Jeevan on 21/12/17.
//  Copyright © 2017 Jeevan. All rights reserved.
//

import UIKit
import MapKit
import Firebase

extension  MKMapView {
    
    
    func zoomToFitAnnoation()  {
    
        if self.annotations.count == 0 {
            return
        }
        
        var topLeftCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        
        var bottomRightCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        for eachAnn in self.annotations where !(eachAnn is DriverAnnotation) {
            
            topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, eachAnn.coordinate.longitude)
            topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, eachAnn.coordinate.latitude)
            bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, eachAnn.coordinate.longitude)
            bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, eachAnn.coordinate.latitude)
            
        }
        
        var region:MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.50
        region.center.longitude = topLeftCoordinate.longitude + (bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 0.50
        region.span.latitudeDelta = fabs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 1.1
        region.span.longitudeDelta = fabs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 1.1
     
        region = self.regionThatFits(region)
        setRegion(region, animated: true)
    }

    func zoomMap(byFactor delta: Double) {
        var region: MKCoordinateRegion = self.region
        var span: MKCoordinateSpan = self.region.span
        span.latitudeDelta *= delta
        span.longitudeDelta *= delta
        region.span = span
        self.setRegion(region, animated: true)
    }

    func setupPaddingForMap() {
        self.setVisibleMapRect(self.visibleMapRect, edgePadding: UIEdgeInsetsMake(100, 0.0, 100, 0.0), animated: true)
    }

    func getImageForRenderAnnotaion(imageSnapperHandler:@escaping(_ imageForSnap:UIImage?)->Void)  {

        let options = MKMapSnapshotOptions()
        options.region = self.region
        options.size = CGSize(width: 250.0, height: 250.0)
        options.scale = UIScreen.main.scale
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot else {
                print("Snapshot error: \(error)")
                fatalError()
            }

            let pin = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
            let image = snapshot.image
            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
            image.draw(at: CGPoint.zero)
            let visibleRect = CGRect(origin: CGPoint.zero, size: image.size)
            let path = UIBezierPath()
            var i = 0

            for (annotation) in self.annotations {
                var point = snapshot.point(for: annotation.coordinate)
                if visibleRect.contains(point) {

                    if i == 0 {

                        path.move(to: point)
                        point.x = point.x + pin.centerOffset.x - (pin.bounds.size.width / 2)
                        point.y = point.y + pin.centerOffset.y - (pin.bounds.size.height / 2)
                        pin.image?.draw(at: point)
                        i = i+1
                    }

                    else {

                        path.addLine(to: point)
                        path.close()
                        point.x = point.x + pin.centerOffset.x - (pin.bounds.size.width / 2)
                        point.y = point.y + pin.centerOffset.y - (pin.bounds.size.height / 2)
                        pin.image?.draw(at: point)
                    }

                }
            }

            UIColor.red.setStroke()
            path.lineWidth = 5.0
            path.stroke()
            path.fill()

            var compositeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            DispatchQueue.main.async(execute: {
                imageSnapperHandler(compositeImage)
            })

        }
    }


    func setupDirection(sourceMapItem:MKMapItem?,destinationMapItem:MKMapItem)  {

        let request = MKDirectionsRequest()
        if let _ = sourceMapItem {

            request.source = sourceMapItem
        }
        else {

            request.source = MKMapItem.forCurrentLocation()

        }

        request.destination = destinationMapItem
        request.requestsAlternateRoutes = false

        request.transportType = .automobile

        let directions = MKDirections(request: request)

        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }

            for route in unwrappedResponse.routes {
                self.add(route.polyline)
               //  self.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }

    func connectuserAndDriverForTripSnap(dataSnap:DataSnapshot) {

        if let status = dataSnap.childSnapshot(forPath: "tripIsAccepted").value as? Bool,let driverKey = dataSnap.childSnapshot(forPath: "driverKey").value as? String,status == true  {
            let currentCoordinateArray = dataSnap.childSnapshot(forPath: "initialCordinate").value  as! NSArray
            let initialCoordinate = currentCoordinateArray.firstObject as! NSArray
            let coordinateUser:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: initialCoordinate[0] as! CLLocationDegrees, longitude: initialCoordinate[1] as! CLLocationDegrees)
            let userAn = UserAnnotation(coordinate: coordinateUser, with: AppConfig.sharedInstance.userID!)
           // self.isTripAcceptted = true

            DataService.instace.REF_DRIVERS.child(driverKey).observeSingleEvent(of: .value, with: { (driverSnap) in

                if  driverSnap.childSnapshot(forPath: "isPickUpModeEnabled").value as? Bool  == true  {
                    let driverCoordinate = driverSnap.childSnapshot(forPath: "coordinate").value  as! NSArray
                    let coordinateDriver:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: driverCoordinate[0] as! CLLocationDegrees, longitude: driverCoordinate[1] as! CLLocationDegrees)
                    let driverAnnotation = DriverAnnotation(coordinate: coordinateDriver, with: driverKey)

                    let placeMarkSource  = MKPlacemark(coordinate: coordinateUser)
                    let sourceMapItem = MKMapItem(placemark: placeMarkSource)
                    let placemarkDestination = MKPlacemark(coordinate: coordinateDriver)
                    let destinationMapItem = MKMapItem(placemark: placemarkDestination)

                    self.layoutMargins = UIEdgeInsets(top: 90, left: 10, bottom: 90, right: 10)
                    self.addAnnotations([userAn,driverAnnotation])
                    self.showAnnotations([userAn,driverAnnotation], animated: true)
                    self.setupDirection(sourceMapItem: sourceMapItem, destinationMapItem: destinationMapItem)
                }
            })
        }
    }
    
}


