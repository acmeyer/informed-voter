//
//  SavedInformationTableViewController.swift
//  informed-voter
//
//  Created by Alex Meyer on 11/1/16.
//  Copyright © 2016 1320 Technologies. All rights reserved.
//

import UIKit
import RealmSwift
import Crashlytics

class SavedInformationTableViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var displayTableSections = [String]()
    var pollingLocations: Results<LocationOffline>!
    var earlyVotingLocations: Results<LocationOffline>!
    var dropOffLocations: Results<LocationOffline>!

    @IBOutlet weak var emptyTableView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTable()
        
        self.tabBarController?.tabBar.items?[1].badgeValue = nil
        
        let defaults = UserDefaults.standard
        defaults.set(0, forKey: "notSeenSavedLocations")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTable() {
        displayTableSections.removeAll()
        
        pollingLocations = realm.objects(LocationOffline.self).filter("type = 'polling-location'")
        earlyVotingLocations = realm.objects(LocationOffline.self).filter("type = 'early-voting-location'")
        dropOffLocations = realm.objects(LocationOffline.self).filter("type = 'dropoff-location'")
        
        if (pollingLocations.count != 0) {
            displayTableSections.append("Polling Locations")
        }
        if (earlyVotingLocations.count != 0) {
            displayTableSections.append("Early Voting Locations")
        }
        if (dropOffLocations.count != 0) {
            displayTableSections.append("Drop-off Locations")
        }
        
        if (pollingLocations.count == 0 && earlyVotingLocations.count == 0 && dropOffLocations.count == 0) {
            emptyTableView.isHidden = false
            self.navigationItem.rightBarButtonItem = nil
        } else {
            emptyTableView.isHidden = true
            self.navigationItem.rightBarButtonItem = self.editButtonItem
        }
        
        self.tableView.reloadData()
    }
    
    func setupUI() {
        self.view.backgroundColor = UIColor(red:0.15, green:0.27, blue:0.75, alpha:1.0)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return displayTableSections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return displayTableSections[section]
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
        header.textLabel?.text = header.textLabel?.text?.capitalized
        header.textLabel?.textColor = UIColor.white
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch displayTableSections[section] {
            case "Polling Locations":
                return pollingLocations.count
            case "Early Voting Locations":
                return earlyVotingLocations.count
            case "Drop-off Locations":
                return dropOffLocations.count
            default:
                return 0
        }
        
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedLocationCell", for: indexPath)

        let section = self.displayTableSections[indexPath.section]
        var locationName = ""
        var addressString = ""
        switch section {
            case "Polling Locations":
                locationName = self.pollingLocations[indexPath.row].name
                addressString = self.pollingLocations[indexPath.row].addressLine1
            case "Early Voting Locations":
                locationName = self.earlyVotingLocations[indexPath.row].name
                addressString = self.earlyVotingLocations[indexPath.row].addressLine1
            case "Drop-off Locations":
                locationName = self.dropOffLocations[indexPath.row].name
                addressString = self.dropOffLocations[indexPath.row].addressLine1
            default:
                break
        }

        
        if locationName == "" {
            cell.textLabel?.text = addressString
        } else {
            cell.textLabel?.text = locationName
        }

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let section = self.displayTableSections[indexPath.section]
        
        if editingStyle == .delete {
            
            switch section {
            case "Polling Locations":
                try! realm.write {
                    realm.delete(self.pollingLocations[indexPath.row])
                }
            case "Early Voting Locations":
                try! realm.write {
                    realm.delete(self.earlyVotingLocations[indexPath.row])
                }
            case "Drop-off Locations":
                try! realm.write {
                    realm.delete(self.dropOffLocations[indexPath.row])
                }
            default:
                break
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)

            setupTable()
        }
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func convertOfflineToLocation(locationOffline: LocationOffline) -> Location {
        var newLocation = Location()
        
        newLocation.name = locationOffline.name
        newLocation.addressLine1 = locationOffline.addressLine1
        newLocation.addressLine2 = locationOffline.addressLine2
        newLocation.addressLine3 = locationOffline.addressLine3
        newLocation.city = locationOffline.city
        newLocation.state = locationOffline.state
        newLocation.zip = locationOffline.zip
        newLocation.pollingHours = locationOffline.pollingHours
        newLocation.startDate = locationOffline.startDate
        newLocation.endDate = locationOffline.endDate
        newLocation.type = locationOffline.type
        newLocation.mapImageData = locationOffline.mapImageData
        
        return newLocation
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showSavedLocationViewSegue") {
            let nextVC = segue.destination as! MainLocationViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow
            let section = self.displayTableSections[(selectedIndexPath?.section)!]
            var location = Location()
            
            switch section {
            case "Polling Locations":
                location = convertOfflineToLocation(locationOffline: self.pollingLocations[(selectedIndexPath?.row)!])
            case "Early Voting Locations":
                location = convertOfflineToLocation(locationOffline: self.earlyVotingLocations[(selectedIndexPath?.row)!])
            case "Drop-off Locations":
                location = convertOfflineToLocation(locationOffline: self.dropOffLocations[(selectedIndexPath?.row)!])
            default:
                break
            }
            
            nextVC.location = location
            nextVC.showSaveButton = false
            
            Answers.logCustomEvent(withName: "Selected saved location cell")
        }
    }

}
