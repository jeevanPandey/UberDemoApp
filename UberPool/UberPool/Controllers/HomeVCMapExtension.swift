//
//  HomeVCMapExtension.swift
//  UberPool
//
//  Created by Jeevan on 04/01/18.
//  Copyright © 2018 Jeevan. All rights reserved.
//

import Foundation
import MapKit

extension HomeVC:MKMapViewDelegate,CAAnimationDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        LocationService.instance.observerLocationValueForUser(withCoordinate: userLocation.coordinate)
        
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        getCoordinateForDrivers()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView:MKAnnotationView?
        if (annotation is DriverAnnotation) {
            
             annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "driverAnnoation")
            if annotationView == nil{
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "driverAnnoation")
                annotationView?.canShowCallout = false
            }else{
                annotationView?.annotation = annotation
            }
            annotationView?.image = #imageLiteral(resourceName: "driverAnnotation")
            
           // return annotationView
            
        }
            
        else if (annotation is UserAnnotation) {
            
             annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "userAnnoation")
            if annotationView == nil{
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userAnnoation")
                annotationView?.canShowCallout = false
            }else{
                annotationView?.annotation = annotation
            }
            annotationView?.image = #imageLiteral(resourceName: "currentLocationAnnotation")
            
           // return annotationView
            
        }
            
        else if (annotation is DestinationAnnotation) {
            
             annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "destination")
            if annotationView == nil{
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "destination")
                annotationView?.canShowCallout = false
            }else{
                annotationView?.annotation = annotation
            }
            annotationView?.image = #imageLiteral(resourceName: "destinationAnnotation")
            
           // return annotationView
            
        }
        if let annView = annotationView {

            annView.setupViewForRippleEffect()

        }
        return annotationView
    }
   
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.lineWidth = 4.0
        renderer.lineDashPhase = 0.5
        renderer.strokeColor = UIColor.blue
        renderer.miterLimit = 5.0
        return renderer
    }

    func animationDidStart(_ anim: CAAnimation) {

        print("start animation")
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print("stop animation")
    }

}
/*
 func avoidDuplicacy() {

 let options = MKMapSnapshotOptions()
 options.region = mapView.region
 options.size = CGSize(width: 250.0, height: 250.0) //mapView.frame.size
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

 for (annotation) in self.mapView.annotations {
 var point = snapshot.point(for: annotation.coordinate)
 if visibleRect.contains(point) {

 if annotation is UserAnnotation {
 path.move(to: point)
 point.x = point.x + pin.centerOffset.x - (pin.bounds.size.width / 2)
 point.y = point.y + pin.centerOffset.y - (pin.bounds.size.height / 2)
 pin.image?.draw(at: point)

 }
 else if annotation is DestinationAnnotation {
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

 let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
 UIGraphicsEndImageContext()

 DispatchQueue.main.async {

 let driverPicker:DriverPickerVC = self.storyboard?.instantiateViewController(withIdentifier: "ToPicker") as! DriverPickerVC
 driverPicker.imageForMap = compositeImage
 self.present(driverPicker, animated: false, completion: nil)
 }
 }
 }
 */
