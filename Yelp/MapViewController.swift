//
//  MapViewController.swift
//  Yelp
//
//  Created by Jiapei Liang on 1/23/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var statusBarBackgroundView: UIView!
    @IBOutlet weak var showCurrentLocationButton: UIButton!

    var business: Business!
    
    var locationManager: CLLocationManager!
    
    var locations: [CLLocation]?
    
    var hasShownCurrentLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        statusBarBackgroundView.backgroundColor = UIColor(red: CGFloat(196/255.0), green: CGFloat(18/255.0), blue: CGFloat(0), alpha: CGFloat(1))
        
        navigationBar.tintColor = UIColor.white
        navigationBar.barTintColor = UIColor(red: CGFloat(196/255.0), green: CGFloat(18/255.0), blue: CGFloat(0), alpha: CGFloat(1))
        navigationBar.topItem?.title = business.name
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        showCurrentLocationButton.layer.cornerRadius = 25
        showCurrentLocationButton.clipsToBounds = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
        
        // set the region to display, this also sets a correct zoom level
        if let coordinate = business.coordinate {
            let latitude = coordinate["latitude"] as! Double
            let longitude = coordinate["longitude"] as! Double
            let centerLocation = CLLocation(latitude: latitude, longitude: longitude)
            goToLocation(location: centerLocation)
            addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // add an Annotation with a coordinate: CLLocationCoordinate2D
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(business.fullAddress!)"
        mapView.addAnnotation(annotation)
    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func showCurrentLocation(_ sender: Any) {
        
        let mapEdgePadding = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        
        var zoomRect: MKMapRect = MKMapRectNull
        
         if let location = self.locations?.first {
            
            let userLocationPoint: MKMapPoint = MKMapPointForCoordinate(location.coordinate)
            let userRect: MKMapRect = MKMapRectMake(userLocationPoint.x, userLocationPoint.y, 0.05, 0.05)
            
            zoomRect = userRect
            
            if let coordinate = business.coordinate {
                
                let latitude = coordinate["latitude"] as! Double
                let longitude = coordinate["longitude"] as! Double
                let businessLocation = CLLocation(latitude: latitude, longitude: longitude)
                
                let businessLocationPoint: MKMapPoint = MKMapPointForCoordinate(businessLocation.coordinate)
                
                let businessRect: MKMapRect = MKMapRectMake(businessLocationPoint.x, businessLocationPoint.y, 0.05, 0.05)
                
                zoomRect = MKMapRectUnion(zoomRect, businessRect)
                
                mapView.setVisibleMapRect(zoomRect, edgePadding: mapEdgePadding, animated: true)
            }
         }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.locations = locations
        
        if !hasShownCurrentLocation {
            self.hasShownCurrentLocation = true
            showCurrentLocation(self)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        
        if let location = self.locations?.first {
            let currentCoordinate = location.coordinate
            let currentPlacemark = MKPlacemark(coordinate: currentCoordinate)
            
            print(2222222222)
            if let coordinate = business.coordinate {
                
                print(3333333333)
                
                let directionsRequest = MKDirectionsRequest()
                
                let latitude = coordinate["latitude"] as! Double
                let longitude = coordinate["longitude"] as! Double
                
                let businessPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(latitude, longitude), addressDictionary: nil)
                
                directionsRequest.source = MKMapItem(placemark: currentPlacemark)
                directionsRequest.destination = MKMapItem(placemark: businessPlacemark)
                
                directionsRequest.transportType = MKDirectionsTransportType.automobile
                
                let directions = MKDirections(request: directionsRequest)
                
                print("calculate")
                
                directions.calculateETA(completionHandler: { (response, error) in
                    print("Estimated arraival time:")
                    print(response!.expectedTravelTime)
                })
                
                
            }
            
            
            
            
        }

        
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func openMap(_ sender: Any) {
        
        
        if let coordinate = self.business.coordinate {
            let latitude = coordinate["latitude"] as! Double
            let longitude = coordinate["longitude"] as! Double
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = business.name
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }
        
        
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
