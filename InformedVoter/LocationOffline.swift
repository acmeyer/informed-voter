//
//  LocationOffline.swift
//  informed-voter
//
//  Created by Alex Meyer on 10/30/16.
//  Copyright © 2016 1320 Technologies. All rights reserved.
//

import Foundation
import RealmSwift

class LocationOffline: Object {
    dynamic var name = ""
    dynamic var locationName = ""
    dynamic var addressLine1 = ""
    dynamic var addressLine2 = ""
    dynamic var addressLine3 = ""
    dynamic var city = ""
    dynamic var state = ""
    dynamic var zip = ""
    dynamic var pollingHours = ""
    dynamic var startDate = ""
    dynamic var endDate = ""
    dynamic var type = ""
    dynamic var mapImageData: NSData?
    
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
