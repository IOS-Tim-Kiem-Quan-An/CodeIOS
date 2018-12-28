//
//  Home3Map.swift
//  GiaoDien
//
//  Created by Cuong on 12/4/18.
//  Copyright © 2018 Cuong. All rights reserved.
//

import UIKit
import MapKit

class Home3Map: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

    @IBOutlet weak var mkview: MKMapView!
    var locationManager = CLLocationManager()
    var annotationArray:[CustomAnnotation] = [CustomAnnotation]()
    override func viewDidLoad() {
        super.viewDidLoad()
        mkview.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.addAnnotationsOnMapView()
        
        //mkview.addAnnotation(annotation)
        
        mkview.addAnnotations(self.annotationArray)
    }
    func addAnnotationsOnMapView(){
        let currentLocation = locationManager.location?.coordinate
        
        let sourceAnnotation = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: (currentLocation?.latitude)!, longitude: (currentLocation?.longitude)!), title: "HERE", subtitle: "Vi tri cua ban")
        
        //10.852511, 106.770261     10.854429, 106.770326
        
        //let currentLocation = CLLocationCoordinate2D(latitude: 10.854429, longitude: 106.770326)
        //let sourceAnnotation = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude), title: "here", subtitle: "27")
        self.annotationArray.append(sourceAnnotation)
        //10.833494, 106.731198   10.851384, 106.772078   10.856202, 106.775501
        
        
        let destinationLocation = CLLocationCoordinate2D(latitude: 10.856202, longitude: 106.775501)
        
        let destinationAnnotation = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: destinationLocation.latitude, longitude: destinationLocation.longitude), title: "den", subtitle: "Diem Den")
    
        self.annotationArray.append(destinationAnnotation)
        
        
        self.DrawTwoLocaltion(sourceLocation: currentLocation!, destinationLocation: destinationLocation)
        
    }
    func DrawTwoLocaltion(sourceLocation: CLLocationCoordinate2D,destinationLocation: CLLocationCoordinate2D)
    {
        //step 1
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        //2
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        //3
        let directRequest = MKDirections.Request()
        
        directRequest.source = sourceMapItem
        
        directRequest.destination = destinationMapItem
        //chon phuong tien di chuyen .automobile la di bang phuong tien
        directRequest.transportType = .automobile
        
        //4
        
        let direction = MKDirections(request: directRequest)
        
        direction.calculate { (response, error) in
            if error == nil
            {
                if let route = response?.routes.first{
                    self.mkview.addOverlay(route.polyline, level: .aboveRoads)
                    
                    let rect = route.polyline.boundingMapRect
                    
                    self.mkview.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 20, right: 20), animated: true)
                    
                }
            }else {
                print(error?.localizedDescription as Any)
            }
        }
        
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let rederer = MKPolylineRenderer(overlay: overlay)
        rederer.strokeColor = UIColor.blue
        rederer.lineWidth = 5.0
        return rederer
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last
        let region = MKCoordinateRegion(center: (currentLocation?.coordinate)!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mkview.setRegion(region, animated: true)
    }
    
    

}//end class
//extension Home3Map:MKMapViewDelegate{
    /*
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annoView:MKAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        annoView.image = UIImage(named: "icons8-home-page-filled-25")
        annoView.frame.size = CGSize(width: 50, height: 50)
        annoView.canShowCallout = true
        return annoView
    }
 */
//}

