//
//  LocationViewController.swift
//  informed-voter
//
//  Created by Alex Meyer on 9/29/16.
//  Copyright © 2016 1320 Technologies. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController {
    
    static let storyboardIdentifier = "LocationViewController"
    
    var location: Location?
    
    @IBOutlet weak var locationView: LocationView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for constraint in contentView.constraints {
            if constraint.identifier == "locationViewConstraint" {
                constraint.constant = locationView.bounds.height + 30
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        self.view.backgroundColor = UIColor(red:0.15, green:0.27, blue:0.75, alpha:1.0)
        
        activityIndicator.startAnimating()
        
        let locationName = self.location?.name
        let addressString = self.location?.shortAddressString()
        if locationName == "" {
            locationView.placeNameLabel.text = addressString
        } else {
            locationView.placeNameLabel.text = locationName
        }
        locationView.addressLabel.text = self.location?.shortAddressString()
        
        
        if self.location!.endDate != "" {
            locationView.datesLabel.text = "\(self.location!.startDate) - \(self.location!.endDate)"
        } else {
            locationView.datesLabel.text = "\(self.location!.startDate)"
        }
        
        locationView.hoursLabel.text = self.location?.pollingHours
        locationView.hoursLabel.sizeToFit()
        
        do {
            let image = try UIImage(data: NSData(contentsOf: Helpers.getGoogleStaticMapUrl(address: self.location!.shortAddressParameter(), size: "large")) as Data)
            locationView.locationImageView.image = image
        } catch {
            print("failed to get map image")
        }
        
        locationView.layer.cornerRadius = 5
        locationView.getDirectionsButton.layer.cornerRadius = 5
        
        locationView.locationImageView.leadingAnchor.constraint(equalTo: locationView.leadingAnchor).isActive = true
        locationView.locationImageView.trailingAnchor.constraint(equalTo: locationView.trailingAnchor).isActive = true
        
        activityIndicator.stopAnimating()
    }
    
    @IBAction func getDirectionsButtonPressed(_ sender: AnyObject) {
        
        self.extensionContext?.open(Helpers.getParentAppUrl(location: self.location!), completionHandler: {(success) in
            print("should open parent app and then map app")
        })
        
    }
}
