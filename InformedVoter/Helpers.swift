//
//  Helpers.swift
//  informed-voter
//
//  Created by Alex Meyer on 9/29/16.
//  Copyright © 2016 1320 Technologies. All rights reserved.
//

import Foundation
import UIKit

struct Helpers {
    static func getGoogleStaticMapUrl(address: String, size: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "maps.googleapis.com"
        components.path = "/maps/api/staticmap"
        
        let markersString = "color:red|\(address)"
        
        let centerQuery = URLQueryItem(name: "center", value: address)
        let markerQuery = URLQueryItem(name: "markers", value: markersString)
        let zoomQuery = URLQueryItem(name: "zoom", value: "16")
        var sizeQuery = URLQueryItem(name: "size", value: "600x300")
        if (size == "large") {
            sizeQuery = URLQueryItem(name: "size", value: "1200x600")
        }
        let maptypeQuery = URLQueryItem(name: "maptype", value: "roadmap")
        let keyQuery = URLQueryItem(name: "key", value: Constants.GOOGLE_PLACES_API_KEY)
        
        components.queryItems = [centerQuery, markerQuery, zoomQuery, sizeQuery, maptypeQuery, keyQuery]
        
        return components.url!
    }
    
    static func getGoogleMapUrl(address: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "maps.google.com"
        
        let destinationAddressQuery = URLQueryItem(name: "daddr", value: address)
        let directionsQuery = URLQueryItem(name: "directionsmode", value: "walking")
        
        components.queryItems = [destinationAddressQuery, directionsQuery]
        
        return components.url!
    }
    
    static func getAppleMapUrl(address: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "maps.apple.com"
        
        let destinationAddressQuery = URLQueryItem(name: "daddr", value: address)
        let directionsQuery = URLQueryItem(name: "dirflag", value: "w")
        
        components.queryItems = [destinationAddressQuery, directionsQuery]
        
        return components.url!
    }
    
    static func getParentAppUrl(location: Location) -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "informedvoter"
        urlComponents.host = "directions"
        urlComponents.queryItems = location.queryItems
        
        return urlComponents.url!
    }
}
