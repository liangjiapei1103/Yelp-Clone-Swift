//
//  DetailViewController.swift
//  Yelp
//
//  Created by Jiapei Liang on 1/23/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DetailViewController: UIViewController {
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    

    var business: Business!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Initialize UITapGestureRecognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showMap))
        mapView.addGestureRecognizer(tapGestureRecognizer)
        
        // Update info
        if let imageURL = business.imageURL {
            restaurantImageView.setImageWith(imageURL)
        }
        
        nameLabel.text = business.name
        distanceLabel.text = business.distance
        if let ratingImageURL = business.ratingImageURL {
            ratingImageView.setImageWith(ratingImageURL)
        }
        
        if let reviewCount = business.reviewCount {
            reviewCountLabel.text = "\(reviewCount) Reviews"
        }
        
        categoriesLabel.text = business.categories
        addressLabel.text = business.address
        
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
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }
    
    // add an Annotation with a coordinate: CLLocationCoordinate2D
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(business.name!)"
        mapView.addAnnotation(annotation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            let destinationController = segue.destination as! MapViewController
            destinationController.business = self.business
            
            destinationController.navigationItem.title = business.name!
        }
    }
    
    func showMap() {
        performSegue(withIdentifier: "showMap", sender: self)
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
