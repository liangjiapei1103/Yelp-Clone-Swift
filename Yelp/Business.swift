//
//  Business.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class Business: NSObject {
    let name: String?
    let address: String?
    let fullAddress: String?
    let city: String?
    let imageURL: URL?
    let categories: String?
    let distance: String?
    let ratingImageURL: URL?
    let reviewCount: NSNumber?
    let coordinate: NSDictionary?
    let phone: String?
    
    init(dictionary: NSDictionary) {
        
        // print(dictionary)
        
        name = dictionary["name"] as? String
        
        phone = dictionary["display_phone"] as? String
        
        let imageURLString = dictionary["image_url"] as? String
        if imageURLString != nil {
            imageURL = URL(string: imageURLString!)!
        } else {
            imageURL = nil
        }
        
        let location = dictionary["location"] as? NSDictionary
        var address = ""
        var city = ""
        var fullAddress = ""
        if location != nil {
            let addressArray = location!["address"] as? NSArray
            if addressArray != nil && addressArray!.count > 0 {
                address = addressArray![0] as! String
            }
            
            let neighborhoods = location!["neighborhoods"] as? NSArray
            if neighborhoods != nil && neighborhoods!.count > 0 {
                if !address.isEmpty {
                    address += ", "
                }
                address += neighborhoods![0] as! String
            }
            
            if let cityName = location!["city"] as? String {
                city = cityName
            }
            
            if let fullAddressArray = location!["display_address"] as? NSArray {
                for i in 0...fullAddressArray.count-1 {
                    if fullAddress != "" {
                        fullAddress = "\(fullAddress), \(fullAddressArray[i])"
                    } else {
                        fullAddress = "\(fullAddressArray[i])"
                    }
                    
                }
                print("Full address: \(fullAddress)")
            }
            
            
            coordinate = location!["coordinate"] as? NSDictionary
            
            // print(coordinate!)
            // print(coordinate!["longitude"])
            
            
        } else {
            coordinate = nil
        }
        
        self.address = address
        self.city = city
        self.fullAddress = fullAddress
        
        let categoriesArray = dictionary["categories"] as? [[String]]
        if categoriesArray != nil {
            var categoryNames = [String]()
            for category in categoriesArray! {
                let categoryName = category[0]
                categoryNames.append(categoryName)
            }
            categories = categoryNames.joined(separator: ", ")
        } else {
            categories = nil
        }
        
        let distanceMeters = dictionary["distance"] as? NSNumber
        if distanceMeters != nil {
            let milesPerMeter = 0.000621371
            distance = String(format: "%.2f mi", milesPerMeter * distanceMeters!.doubleValue)
        } else {
            distance = nil
        }
        
        let ratingImageURLString = dictionary["rating_img_url_large"] as? String
        if ratingImageURLString != nil {
            ratingImageURL = URL(string: ratingImageURLString!)
        } else {
            ratingImageURL = nil
        }
        
        reviewCount = dictionary["review_count"] as? NSNumber
    }
    
    class func businesses(array: [NSDictionary]) -> [Business] {
        var businesses = [Business]()
        for dictionary in array {
            let business = Business(dictionary: dictionary)
            businesses.append(business)
        }
        return businesses
    }
    
    class func searchWithTerm(term: String, completion: @escaping ([Business]?, Error?) -> Void) {
        _ = YelpClient.sharedInstance.searchWithTerm(term, completion: completion)
    }
    
    class func searchWithTerm(term: String, offset: Int, completion: @escaping ([Business]?, Error?) -> Void) {
        _ = YelpClient.sharedInstance.searchWithTerm(term, offset: offset, completion: completion)
    }
    
    class func searchWithTerm(term: String, sort: YelpSortMode, offset: Int, radiusFilter: Int, limit: Int, completion: @escaping ([Business]?, Error?) -> Void) {
        _ = YelpClient.sharedInstance.searchWithTerm(term, sort: sort, offset: offset, radiusFilter: radiusFilter, limit: limit, completion: completion)
    }
    
    class func searchWithTerm(term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, offset: Int?, radiusFilter: Int?, limit: Int?, completion: @escaping ([Business]?, Error?) -> Void) -> Void {
        _ = YelpClient.sharedInstance.searchWithTerm(term, sort: sort, categories: categories, deals: deals, offset: offset, radiusFilter: radiusFilter!, limit: limit!, completion: completion)
    }
}
