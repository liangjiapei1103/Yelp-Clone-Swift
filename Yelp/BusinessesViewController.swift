//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit
import MBProgressHUD
import ReachabilitySwift

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate{
    
    var businesses: [Business]!
    
    var selectedBusiness : Business!
    
    var filteredBusinesses: [Business]!
    
    var isMoreDateLoading = false
    
    var loadingMoreView: InfiniteScrollActivityView?
    
    var offset = 10
    
    var sortingOption = YelpSortMode.bestMatched
    
    var isSearching = false
    
    var searchText: String! = ""
    
    var noMoreResults = false
    
    var searchBar: UISearchBar!
    
    var flipped = false
    
    var annotations: [MKPointAnnotation]! = []
    
    var locationManager: CLLocationManager!
    
    var locations: [CLLocation]?
    
    let defaults = UserDefaults.standard
    
    // ReachabilitySwift Init
    //declare this property where it won't go out of scope relative to your listener
    let reachability = Reachability()!
    
    @IBOutlet weak var mapBarItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var showCurrentLocationButton: UIButton!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var filterOptionsView: UIView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterOptionsSegmentControl: UISegmentedControl!
    
    var cardViews : (frontView: UIView, backView: UIView)!
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
    }
    
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
                networkErrorView.isHidden = true
            } else {
                print("Reachable via Cellular")
                networkErrorView.isHidden = true
            }
        } else {
            print("Network not reachable")
            networkErrorView.isHidden = false
        }
    }
    
    
    @IBAction func hideNetworkErrorView(_ sender: Any) {
        networkErrorView.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi {
                    print("Reachable via WiFi")
                } else if reachability.isReachableViaWWAN {
                    print("Reachable via Cellular")
                } else {
                    print("Not reachable")
                }
            }
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi {
                    print("Reachable via WiFi")
                } else if reachability.isReachableViaWWAN {
                    print("Reachable via Cellular")
                } else {
                    print("Not reachable")
                }
            }
        }
        
        
        
        showCurrentLocationButton.layer.cornerRadius = 25
        showCurrentLocationButton.clipsToBounds = true
        
        tableView.tableFooterView = UIView(frame: .zero)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        // Set up Infinite Scroll Loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        if let searchText = defaults.object(forKey: "searchText") as? String {
            self.searchText = searchText
        } else {
            self.searchText = "Restaurants"
        }
        
        
        // create the search bar programatically since you won't be
        // able to drag one onto the navigation bar
        searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.text = self.searchText
        // searchBar.tintColor = UIColor(red: CGFloat(196/255.0), green: CGFloat(18/255.0), blue: CGFloat(0), alpha: CGFloat(1))
        
        // The delegate property of search bar must be set to an object that implements UISearchBarDelegate
        searchBar.delegate = self
        
        searchBar.placeholder = "Search restaurant here"
        
        
        // the UIViewController comes with a navigationItem property
        // this will automatically be initialized for you if when the
        // view controller is added to a navigation controller's stack
        // you just need to set the titleView to be the search bar
        navigationItem.titleView = searchBar
    
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        
        // Update navigation bar barTintColor and tintColor
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.tintColor = UIColor.white
            navigationBar.barTintColor = UIColor(red: CGFloat(196/255.0), green: CGFloat(18/255.0), blue: CGFloat(0), alpha: CGFloat(1))
        }
        
        
        
        doSearch(searchText: self.searchText)
        
       
        
        
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setFilterOption(_ sender: Any) {
        
        if filterOptionsSegmentControl.selectedSegmentIndex == 0 {
            self.sortingOption = YelpSortMode.bestMatched
        } else if filterOptionsSegmentControl.selectedSegmentIndex == 1 {
            self.sortingOption = YelpSortMode.distance
        } else {
            self.sortingOption = YelpSortMode.highestRated
        }
        
        doSearch(searchText: self.searchText)
        
        
    }
    
    @IBAction func toggleFilterOptionsView(_ sender: Any) {

        filterOptionsView.isHidden = !filterOptionsView.isHidden
        
        if filterOptionsView.isHidden {
            
            tableViewTopConstraint.constant = 0;
            self.view.layoutIfNeeded()
        } else {
            
            tableViewTopConstraint.constant = 56;
            self.view.layoutIfNeeded()
        }
        
        
        
    }
    
    
    func showDetailViaMap() {
        performSegue(withIdentifier: "showDetailViaMap", sender: self)
    }
    
    @IBAction func flipView(_ sender: Any) {
        if flipped {
            
            mapBarItem.title = "Map"
            mapBarItem.isEnabled = false

            UIView.transition(with: self.view, duration: 0.7, options: .transitionFlipFromLeft, animations: {
                
                self.view.bringSubview(toFront: self.tableView)
                self.view.bringSubview(toFront: self.filterOptionsView)
            }) { (success) in
                if (success) {
                    self.mapBarItem.isEnabled = true
                    self.flipped = !self.flipped
                }
            }
            
        } else {
            
            mapBarItem.title = "List"
            mapBarItem.isEnabled = false
            
            UIView.transition(with: self.view, duration: 0.7, options: .transitionFlipFromRight, animations: {
                
                self.view.bringSubview(toFront: self.mapContainerView)
                self.view.bringSubview(toFront: self.filterOptionsView)
                
            }) { (success) in
                if (success) {
                    self.mapBarItem.isEnabled = true
                    self.flipped = !self.flipped
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if filteredBusinesses != nil {
            return filteredBusinesses.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        
        cell.business = filteredBusinesses[indexPath.row]
        
        return cell
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Handle scroll behavior here
        if (!isMoreDateLoading && !isSearching && !noMoreResults && businesses != nil && reachability.isReachable) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollViewOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if (scrollView.contentOffset.y > scrollViewOffsetThreshold && tableView.isDragging) {
                isMoreDateLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView?.startAnimating()
                
                Business.searchWithTerm(term: self.searchText, sort: self.sortingOption, offset: self.offset, radiusFilter: 40000, limit: 10, completion: { (businesses: [Business]?, error: Error?) -> Void in
                    
                        if let businesses = businesses {
                            
                            if businesses.count == 0 {
                                print("No new results received")
                                self.noMoreResults = true
                                // Update flag
                                self.isMoreDateLoading = false
                                // Stop the loading indicator
                                self.loadingMoreView!.stopAnimating()
                                
                                let tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 50))
                                tableViewFooter.backgroundColor = UIColor.white
                                let version = UILabel(frame: CGRect(x: 8, y: 15, width: self.tableView.frame.width, height: 30))
                                version.font = version.font.withSize(14)
                                version.text = "No more restaurants"
                                version.textColor = UIColor.lightGray
                                version.textAlignment = .center
                                
                                tableViewFooter.addSubview(version)
                                
                                self.tableView.tableFooterView  = tableViewFooter
                                
                                return
                            }
                            
                            for business in businesses {
                                self.businesses.append(business)
                            }
                            
                            if businesses.count < 10 {
                                let tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 50))
                                tableViewFooter.backgroundColor = UIColor.white
                                let version = UILabel(frame: CGRect(x: 8, y: 15, width: self.tableView.frame.width, height: 30))
                                version.font = version.font.withSize(14)
                                version.text = "No more restaurants"
                                version.textColor = UIColor.lightGray
                                version.textAlignment = .center
                                
                                tableViewFooter.addSubview(version)
                                
                                self.tableView.tableFooterView  = tableViewFooter
                                
                                self.noMoreResults = true
                            }
 
                            
                            
                        }
                    
                        self.filteredBusinesses = self.businesses
                    
                        // Update flag
                        self.isMoreDateLoading = false
                        self.offset += 10
                    
                        // Stop the loading indicator
                        self.loadingMoreView!.stopAnimating()
                    
                        self.tableView.reloadData()
                    
                        self.createMap(completionHandler: {(success) -> Void in
                        
                            if success {
                            
                                self.fitMapViewToAnnotationList(annotations: self.annotations!)
                            
                                print("Success")
                            }
                        
                        })
                    
                    }
                )
                
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            let business = filteredBusinesses![indexPath!.row]
            
            
            let detailViewController = segue.destination as! DetailViewController
            
            detailViewController.business = business
            
            detailViewController.navigationItem.title = business.name! as String
            
            
            // Deselect collection view after segue
            self.tableView.deselectRow(at: indexPath!, animated: true)
        } else if segue.identifier == "showDetailViaMap" {
            
            let detailViewController = segue.destination as! DetailViewController
            
            detailViewController.business = self.selectedBusiness
            
            detailViewController.navigationItem.title = self.selectedBusiness.name! as String
            
        }
        
 
    }
    
    func doSearch(searchText: String) {
        
        if self.reachability.isReachable {
            print("has network")
        } else {
            print("No network")
            return
        }
        
        self.searchText = searchText
        annotations = []
        self.offset = 5;
        self.noMoreResults = false
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        defaults.set(searchText, forKey: "searchText")
        
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        Business.searchWithTerm(term: searchText, sort: self.sortingOption, offset: 0, radiusFilter: 40000, limit: 10, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            if businesses == nil {
                
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hide(for: self.view, animated: true)
                
                return
            } else {
            
                self.businesses = businesses
                
                self.filteredBusinesses = businesses
                
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hide(for: self.view, animated: true)
                
                self.tableView.reloadData()
                
                if (businesses?.count)! < 10 {
                    let tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 50))
                    tableViewFooter.backgroundColor = UIColor.white
                    let version = UILabel(frame: CGRect(x: 8, y: 15, width: self.tableView.frame.width, height: 30))
                    version.font = version.font.withSize(14)
                    version.text = "No more restaurants"
                    version.textColor = UIColor.lightGray
                    version.textAlignment = .center
                    
                    tableViewFooter.addSubview(version)
                    
                    self.tableView.tableFooterView  = tableViewFooter
                    
                    self.noMoreResults = true
                }
                
                self.createMap(completionHandler: {(success) -> Void in
                    
                    if success {
                        
                        self.fitMapViewToAnnotationList(annotations: self.annotations!)
                        
                        self.mapView.selectAnnotation(self.annotations[0], animated: true)
                        
                        print("Success")
                    }
                    
                })
                
            }
        }
        )
    }
    
    func createMap(completionHandler:@escaping (Bool) -> ()) {
        
        for index in 0...filteredBusinesses.count-1 {
            // set the region to display, this also sets a correct zoom level
            if let coordinate = self.filteredBusinesses[index].coordinate {
                let latitude = coordinate["latitude"] as! Double
                let longitude = coordinate["longitude"] as! Double
                let centerLocation = CLLocation(latitude: latitude, longitude: longitude)
                
                if index == 0 {
                    self.goToLocation(location: centerLocation)
                }
                
                self.addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), index: index)
            }
            
            if index == filteredBusinesses.count-1 {
                completionHandler(true)
            }
        }
        
        
    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
        
    }
    
    // add an Annotation with a coordinate: CLLocationCoordinate2D
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D, index: Int) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(filteredBusinesses[index].name!)"
        annotation.subtitle = filteredBusinesses[index].fullAddress
        mapView.addAnnotation(annotation)
        
        self.annotations.append(annotation)
    }
    
    func fitMapViewToAnnotationList(annotations: [MKPointAnnotation]) -> Void {
        
        let mapEdgePadding = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        
        var zoomRect: MKMapRect = MKMapRectNull
        
        
        
        for index in 0..<annotations.count {
            let annotation = annotations[index]
            let aPoint : MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
            let rect : MKMapRect = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
            
            if MKMapRectIsNull(zoomRect) {
                zoomRect = rect
            } else {
                zoomRect = MKMapRectUnion(zoomRect, rect)
            }
        }
        
        if let location = self.locations?.first {
            
            let userLocationPoint: MKMapPoint = MKMapPointForCoordinate(location.coordinate)
            let userRect: MKMapRect = MKMapRectMake(userLocationPoint.x, userLocationPoint.y, 0.05, 0.05)
            
            zoomRect = MKMapRectUnion(zoomRect, userRect)
            print("User location included")
        }
        
        mapView.setVisibleMapRect(zoomRect, edgePadding: mapEdgePadding, animated: true)
        
    }

    @IBAction func showCurrentLocation(_ sender: Any) {
        
        // print(self.annotations)
        
        fitMapViewToAnnotationList(annotations: annotations!)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.locations = locations
        
        print("locations: ")
        print(locations)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        // Reuse the annotation if possible
        var annotationView : MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        }
        
        let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        
        for business in businesses {
                if business.name! == annotation.title! {
                    if business.imageURL == nil {
                        leftIconView.image = UIImage(named: "restaurant")
                    } else {
                        leftIconView.setImageWith(business.imageURL!)
                    }
                    
                    annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                    
                    let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(showDetailViaMap))
                    let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(showDetailViaMap))
                    
                    annotationView?.leftCalloutAccessoryView = leftIconView
                    
                    annotationView?.leftCalloutAccessoryView?.isUserInteractionEnabled = true
                    annotationView?.rightCalloutAccessoryView?.isUserInteractionEnabled = true
                    
                    annotationView?.leftCalloutAccessoryView?.addGestureRecognizer(tapGestureRecognizer1)
                    annotationView?.rightCalloutAccessoryView?.addGestureRecognizer(tapGestureRecognizer2)

                }
        }
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        for business in businesses {
            if business.name! == view.annotation!.title! {
                self.selectedBusiness = business
                print((view.annotation!.title!)!)
            }
        }

    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// SearchBar methods
extension BusinessesViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("isSearching: \(isSearching)")
        self.searchText = searchText
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        isSearching = true
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        isSearching = false
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
        print("isSearching: \(isSearching)")
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
        print("isSearching: \(isSearching)")
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
 
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearching = false
        doSearch(searchText: self.searchText)
    }
}
