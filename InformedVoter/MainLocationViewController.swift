//
//  MainLocationViewController.swift
//  informed-voter
//
//  Created by Alex Meyer on 9/29/16.
//  Copyright © 2016 1320 Technologies. All rights reserved.
//

import UIKit
import Crashlytics
import RealmSwift
import SVProgressHUD

class MainLocationViewController: UIViewController {
    
    let realm = try! Realm()
    
    var location: Location?
    
    var showSaveButton = true

    @IBOutlet weak var locationView: LocationView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        Answers.logContentView(withName: "Location View", contentType: "View", contentId: self.location?.name)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for constraint in contentView.constraints {
            if constraint.identifier == "locationViewConstraint" {
                constraint.constant = locationView.bounds.height + 30
            }
        }
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
        
        if let imageData = self.location?.mapImageData {
            let image = UIImage(data: imageData as Data)
            locationView.locationImageView.image = image
        } else {
            do {
                let image = try UIImage(data: NSData(contentsOf: Helpers.getGoogleStaticMapUrl(address: self.location!.shortAddressParameter(), size: "large")) as Data)
                locationView.locationImageView.image = image
            } catch {
                // set image to missing image
                let image = UIImage(named: "missing-image.png")
                locationView.locationImageView.image = image
            }
        }
        
        locationView.layer.cornerRadius = 5
        locationView.getDirectionsButton.layer.cornerRadius = 5
        
        locationView.locationImageView.leadingAnchor.constraint(equalTo: locationView.leadingAnchor).isActive = true
        locationView.locationImageView.trailingAnchor.constraint(equalTo: locationView.trailingAnchor).isActive = true
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(shareLocation))
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(saveLocation))
        
        if (showSaveButton) {
            self.navigationItem.rightBarButtonItems = [shareButton, saveButton]
        } else {
            self.navigationItem.rightBarButtonItem = shareButton
        }
        
        activityIndicator.stopAnimating()
    }
    
    @IBAction func getDirectionsButtonPressed(_ sender: AnyObject) {
        
        Answers.logCustomEvent(withName: "Get directions button pressed")
        
        if let address = self.location?.shortAddressParameter() {
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                UIApplication.shared.open(Helpers.getGoogleMapUrl(address: address), options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.open(Helpers.getAppleMapUrl(address: address), options: [:], completionHandler: nil)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveLocation() {
        let newLocation = LocationOffline()
        if let name = location?.name {
            newLocation.name = name
        }
        if let addressLine1 = location?.addressLine1 {
            newLocation.addressLine1 = addressLine1
        }
        if let addressLine2 = location?.addressLine2 {
            newLocation.addressLine2 = addressLine2
        }
        if let addressLine3 = location?.addressLine3 {
            newLocation.addressLine3 = addressLine3
        }
        if let city = location?.city {
            newLocation.city = city
        }
        if let state = location?.state {
            newLocation.state = state
        }
        if let zip = location?.zip {
            newLocation.zip = zip
        }
        if let pollingHours = location?.pollingHours {
            newLocation.pollingHours = pollingHours
        }
        if let startDate = location?.startDate {
            newLocation.startDate = startDate
        }
        if let endDate = location?.endDate {
            newLocation.endDate = endDate
        }
        if let type = location?.type {
            newLocation.type = type
        }
        if let imageData = NSData(contentsOf: Helpers.getGoogleStaticMapUrl(address: newLocation.shortAddressParameter(), size: "large")) {
            newLocation.mapImageData = imageData as NSData?
        }
        try! realm.write {
            realm.add(newLocation)
        }
        
        SVProgressHUD.showSuccess(withStatus: "Location saved!")
        
        let defaults = UserDefaults.standard
        var notSeen = defaults.integer(forKey: "notSeenSavedLocations")
        
        if notSeen != 0 {
            notSeen += 1
            defaults.set(notSeen, forKey: "notSeenSavedLocations")
            self.tabBarController?.tabBar.items?[1].badgeValue = String(notSeen)
        } else {
            defaults.set(1, forKey: "notSeenSavedLocations")
            self.tabBarController?.tabBar.items?[1].badgeValue = "1"
        }
        
        Answers.logCustomEvent(withName: "Saved Location", customAttributes: ["Address": newLocation.addressLine1])
    }
    
    func shareLocation() {
        var messageText = "Here's some polling location information you might find handy for the election: \n\n"
        if let addressString = location?.shortAddressString() {
            messageText += "Address: "
            messageText += addressString
            messageText += "\n"
        }
        if let pollingHours = location?.pollingHours {
            messageText += "Hours: "
            messageText += pollingHours
            messageText += "\n\n"
        }
        
        Answers.logCustomEvent(withName: "Share location info pressed", customAttributes: ["Address": location?.addressLine1 ?? ""])
        
        if let address = location?.shortAddressParameter() {
            let mapUrl = Helpers.getGoogleMapUrl(address: address)
            
            let activityVC = UIActivityViewController(activityItems: [messageText, mapUrl], applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }

}
