//
//  MapTableViewCell.swift
//  Yelp
//
//  Created by Jiapei Liang on 2/20/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapTableViewCell: UITableViewCell {

    var business: Business! {
        didSet {
            if let coordinate = business.coordinate {
                let latitude = coordinate["latitude"] as! Double
                let longitude = coordinate["longitude"] as! Double
                let centerLocation = CLLocation(latitude: latitude, longitude: longitude)
                goToLocation(location: centerLocation)
                addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
        }
    }
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }
    
    // add an Annotation with a coordinate: CLLocationCoordinate2D
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        // annotation.title = "\(business.name!)"
        mapView.addAnnotation(annotation)
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
