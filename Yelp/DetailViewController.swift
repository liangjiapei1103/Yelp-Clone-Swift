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

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var tableView: UITableView!

    var business: Business!
    
    var locationManager: CLLocationManager!
    
    var locations: [CLLocation]?
    
    var hasCalculatedETA = false
    
    var ETA = "Estimating"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        } else if section == 1 {
            return 0
        } else if section == 2 {
            return 10
        } else if section == 3 {
            return 0
        } else if section == 4 {
            return 0
        } else if section == 5 {
            return 10
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell") as! InfoTableViewCell
            
            cell.selectionStyle = .none
            
            cell.business = self.business
            
            return cell
            
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell") as! MapTableViewCell
            
            cell.business = self.business
            
            return cell
            
        } else if indexPath.section == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell") as! AddressTableViewCell
            
            cell.addressLabel.text = business.fullAddress
            
            cell.accessoryType = .disclosureIndicator
            
            return cell
            
        } else if indexPath.section == 3 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DirectionsCell") as! DirectionsTableViewCell
            
            cell.ETALabel.text = self.ETA
            
            
            cell.accessoryType = .disclosureIndicator
            
            return cell
            
        } else if indexPath.section == 4 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CallCell") as! CallTableViewCell
            
            cell.phoneLabel.text = business.phone
            
            cell.accessoryType = .disclosureIndicator
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MoreInfoCell")
            
            cell?.accessoryType = .disclosureIndicator
            
            return cell!
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)!
        
        if cell.reuseIdentifier == "AddressCell" {
            performSegue(withIdentifier: "showMap", sender: self)
        } else if cell.reuseIdentifier == "CallCell" {
            print("Call \(business.phone!)")
            guard let number = URL(string: "tel://7653373440") else { return }
            UIApplication.shared.open(number, options: [:], completionHandler: nil)
        } else if cell.reuseIdentifier == "DirectionsCell" {
            if let coordinate = self.business.coordinate {
                let latitude = coordinate["latitude"] as! Double
                let longitude = coordinate["longitude"] as! Double
                let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
                mapItem.name = business.name
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
            }
        }
        
        // Deselect collection view after segue
        self.tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.locations = locations
        
        
        if !hasCalculatedETA {
            if let location = self.locations?.first {
                let currentCoordinate = location.coordinate
                let currentPlacemark = MKPlacemark(coordinate: currentCoordinate)
                
                if let coordinate = business.coordinate {
                    
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
                        
                        self.ETA = "\(Int(ceil(response!.expectedTravelTime / 60))) min"
                        
                        print(self.ETA)
                        
                        let cell = self.tableView.dequeueReusableCell(withIdentifier: "DirectionsCell") as! DirectionsTableViewCell
                        
                        cell.ETALabel.text = self.ETA
                        
                        self.tableView.reloadData()
                        
                        self.hasCalculatedETA = true
                    })
                }
            }
            
        }
    
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            let destinationController = segue.destination as! MapViewController
            destinationController.business = self.business
            
            destinationController.navigationItem.title = business.name!
        }
    }

    @IBAction func showMap(_ sender: UITapGestureRecognizer) {
        
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
