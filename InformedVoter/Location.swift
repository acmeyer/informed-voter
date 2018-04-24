//
//  Location.swift
//  informed-voter
//
//  Created by Alex Meyer on 9/29/16.
//  Copyright © 2016 1320 Technologies. All rights reserved.
//

import Foundation
import Messages

struct Location {
    var name = ""
    var locationName = ""
    var addressLine1 = ""
    var addressLine2 = ""
    var addressLine3 = ""
    var city = ""
    var state = ""
    var zip = ""
    var pollingHours = ""
    var startDate = ""
    var endDate = ""
    var type = ""
    var mapImageData: NSData?
    
    func shortAddressString() -> String {
        var result = self.addressLine1
        
        if (self.addressLine2 != "") {
            result += " " + self.addressLine2
        }
        
        if (self.addressLine3 != "") {
            result += " " + self.addressLine3
        }
        
        result += "\n\(self.city), \(self.state) \(self.zip)"
        return result
    }
    
    func shortAddressParameter() -> String {
        return self.shortAddressString().replacingOccurrences(of: " ", with: "+").replacingOccurrences(of: ".", with: "")
    }
}

extension Location {
    
    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        
        items.append(URLQueryItem(name: "address", value: shortAddressParameter()))
        items.append(URLQueryItem(name: "name", value: name))
        items.append(URLQueryItem(name: "locationName", value: locationName))
        items.append(URLQueryItem(name: "addressLine1", value: addressLine1))
        items.append(URLQueryItem(name: "addressLine2", value: addressLine2))
        items.append(URLQueryItem(name: "addressLine3", value: addressLine3))
        items.append(URLQueryItem(name: "city", value: city))
        items.append(URLQueryItem(name: "state", value: state))
        items.append(URLQueryItem(name: "zip", value: zip))
        items.append(URLQueryItem(name: "pollingHours", value: pollingHours))
        items.append(URLQueryItem(name: "startDate", value: startDate))
        items.append(URLQueryItem(name: "endDate", value: endDate))
        items.append(URLQueryItem(name: "type", value: type))
        
        return items
    }
    
    init?(queryItems: [URLQueryItem]) {
        var name = ""
        var locationName = ""
        var addressLine1 = ""
        var addressLine2 = ""
        var addressLine3 = ""
        var city = ""
        var state = ""
        var zip = ""
        var pollingHours = ""
        var startDate = ""
        var endDate = ""
        var type = ""
        
        for queryItem in queryItems {
            guard let value = queryItem.value else { continue }
            
            
            switch queryItem.name {
            case "name":
                name = value
            case "locationName":
                locationName = value
            case "addressLine1":
                addressLine1 = value
            case "addressLine2":
                addressLine2 = value
            case "addressLine3":
                addressLine3 = value
            case "city":
                city = value
            case "state":
                state = value
            case "zip":
                zip = value
            case "pollingHours":
                pollingHours = value
            case "startDate":
                startDate = value
            case "endDate":
                endDate = value
            case "type":
                type = value
            default: break
            }
            
        }
        
        
        self.name = name
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.addressLine3 = addressLine3
        self.city = city
        self.state = state
        self.zip = zip
        self.locationName = locationName
        self.pollingHours = pollingHours
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
    }
}

extension Location {
    init?(message: MSMessage?) {
        guard let messageURL = message?.url else { return nil }
        guard let urlComponents = NSURLComponents(url: messageURL, resolvingAgainstBaseURL: false), let queryItems = urlComponents.queryItems else { return nil }
        
        self.init(queryItems: queryItems)
    }
}
