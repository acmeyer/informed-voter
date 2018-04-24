//
//  SearchViewController.swift
//  informed-voter
//
//  Created by Alex Meyer on 9/29/16.
//  Copyright © 2016 1320 Technologies. All rights reserved.
//

import UIKit
import GooglePlaces
import Alamofire
import SwiftyJSON

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: SearchViewControllerDelegate?
    
    var displayTableSections = [String]()
    var displayTableItems = [[Location]]()
    
    static let storyboardIdentifier = "SearchViewController"
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var displayTableView: UITableView!
    @IBOutlet weak var resultsLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        searchController?.searchBar.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UI
    func setupUI() {
        self.view.backgroundColor = UIColor(red:0.15, green:0.27, blue:0.75, alpha:1.0)
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        headerView.addSubview((searchController?.searchBar)!)
        searchController?.searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchController?.searchBar.tintColor = UIColor.lightText
        
        // SearchBar TextField style
        let textFieldInsideSearchBar = searchController?.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        
        // SearchBar Search Icon style
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        glassIconView?.tintColor = UIColor.lightText
        
        // SearchBar Placeholder Text Style
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = UIColor.lightText
        
        searchController?.searchBar.placeholder = "Enter Friend's Address"
        
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        resultsViewController?.tableCellBackgroundColor = UIColor(red:0.15, green:0.27, blue:0.75, alpha:1.0)
        
        resultsViewController?.primaryTextHighlightColor = UIColor.white
        resultsViewController?.primaryTextColor = UIColor.lightText
        resultsViewController?.secondaryTextColor = UIColor.lightText
        resultsViewController?.tableCellSeparatorColor = UIColor.lightText
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true
        
        displayTableView.delegate = self
        displayTableView.dataSource = self
        
        displayTableView.backgroundColor = UIColor.clear
    }
    
    func goBack() {
        print("go back")
    }
    
    // TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.displayTableSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayTableItems[section].count
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightLight)
        header.textLabel?.text = header.textLabel?.text?.capitalized
        header.textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return displayTableSections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell")! as! LocationTableViewCell
        
        let locationName = self.displayTableItems[indexPath.section][indexPath.row].name
        let addressString = self.displayTableItems[indexPath.section][indexPath.row].shortAddressString()
        if locationName == "" {
            cell.locationNameLabel.text = addressString
            cell.addressLabel.text = ""
        } else {
            cell.locationNameLabel.text = locationName
            cell.addressLabel.text = addressString
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.searchViewController(self, didSelect: displayTableItems[indexPath.section][indexPath.row])
    }
}

// Handle the user's selection.
extension SearchViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        
        let address = place.formattedAddress!.replacingOccurrences(of: " ", with: "+").replacingOccurrences(of: ",", with: "")
        
        let url = "\(Constants.VOTER_API)?address=\(address)&electionId=\(Constants.ELECTION_ID)&key=\(Constants.GOOGLE_PLACES_API_KEY)";
        
        activityIndicator.startAnimating()
        
        // reset displayTableView
        displayTableSections.removeAll()
        displayTableItems.removeAll()
        
        Alamofire.request(url)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    
                    var jsonPollingLocationsExist = false
                    var jsonEarlyVotingLocationsExist = false
                    var jsonDropOffLocationsExist = false
                    
                    if let jsonPollingLocations = json["pollingLocations"].array {
                        jsonPollingLocationsExist = true
                        
                        var pollingLocations = [Location]()
                        for (locJson):(JSON) in jsonPollingLocations {
                            var location = Location()
                            if locJson["address"] != nil {
                                if let name = locJson["address"]["locationName"].string {
                                    location.name = name
                                }
                                if let line1 = locJson["address"]["line1"].string {
                                    location.addressLine1 = line1
                                }
                                if let line2 = locJson["address"]["line2"].string {
                                    location.addressLine2 = line2
                                }
                                if let line3 = locJson["address"]["line3"].string {
                                    location.addressLine3 = line3
                                }
                                if let city = locJson["address"]["city"].string {
                                    location.city = city
                                }
                                if let state = locJson["address"]["state"].string {
                                    location.state = state
                                }
                                if let zip = locJson["address"]["zip"].string {
                                    location.zip = zip
                                }
                            }
                            if let name = locJson["name"].string {
                                location.name = name
                            }
                            if let pollingHours = locJson["pollingHours"].string {
                                location.pollingHours = pollingHours
                            }
                            if let startDate = locJson["startDate"].string {
                                location.startDate = startDate
                            } else {
                                location.startDate = "November 8th, 2016"
                            }
                            if let endDate = locJson["endDate"].string {
                                location.endDate = endDate
                            }
                            location.type = "polling-location"
                            pollingLocations.append(location)
                        }
                        
                        self.displayTableItems.append(pollingLocations)
                        self.displayTableSections.append("Polling Places")
                    }
                    
                    if let jsonEarlyVotingLocations = json["earlyVoteSites"].array {
                        jsonEarlyVotingLocationsExist = true
                        
                        var earlyVotingLocations = [Location]()
                        for (locJson):(JSON) in jsonEarlyVotingLocations {
                            var location = Location()
                            if locJson["address"] != nil {
                                if let name = locJson["address"]["locationName"].string {
                                    location.name = name
                                }
                                if let line1 = locJson["address"]["line1"].string {
                                    location.addressLine1 = line1
                                }
                                if let line2 = locJson["address"]["line2"].string {
                                    location.addressLine2 = line2
                                }
                                if let line3 = locJson["address"]["line3"].string {
                                    location.addressLine3 = line3
                                }
                                if let city = locJson["address"]["city"].string {
                                    location.city = city
                                }
                                if let state = locJson["address"]["state"].string {
                                    location.state = state
                                }
                                if let zip = locJson["address"]["zip"].string {
                                    location.zip = zip
                                }
                            }
                            if let name = locJson["name"].string {
                                location.name = name
                            }
                            if let pollingHours = locJson["pollingHours"].string {
                                location.pollingHours = pollingHours
                            }
                            if let startDate = locJson["startDate"].string {
                                location.startDate = startDate
                            } else {
                                location.startDate = "November 8th, 2016"
                            }
                            if let endDate = locJson["endDate"].string {
                                location.endDate = endDate
                            }
                            location.type = "early-voting-location"
                            earlyVotingLocations.append(location)
                        }
                        
                        self.displayTableItems.append(earlyVotingLocations)
                        self.displayTableSections.append("Early Voting Sites")
                    }
                    
                    if let jsonDropOffLocations = json["dropOffLocations"].array {
                        jsonDropOffLocationsExist = true
                        
                        var dropOffLocations = [Location]()
                        for (locJson):(JSON) in jsonDropOffLocations {
                            var location = Location()
                            if locJson["address"] != nil {
                                if let name = locJson["address"]["locationName"].string {
                                    location.name = name
                                }
                                if let line1 = locJson["address"]["line1"].string {
                                    location.addressLine1 = line1
                                }
                                if let line2 = locJson["address"]["line2"].string {
                                    location.addressLine2 = line2
                                }
                                if let line3 = locJson["address"]["line3"].string {
                                    location.addressLine3 = line3
                                }
                                if let city = locJson["address"]["city"].string {
                                    location.city = city
                                }
                                if let state = locJson["address"]["state"].string {
                                    location.state = state
                                }
                                if let zip = locJson["address"]["zip"].string {
                                    location.zip = zip
                                }
                            }
                            if let name = locJson["name"].string {
                                location.name = name
                            }
                            if let pollingHours = locJson["pollingHours"].string {
                                location.pollingHours = pollingHours
                            }
                            if let startDate = locJson["startDate"].string {
                                location.startDate = startDate
                            } else {
                                location.startDate = "November 8th, 2016"
                            }
                            if let endDate = locJson["endDate"].string {
                                location.endDate = endDate
                            }
                            location.type = "dropoff-location"
                            dropOffLocations.append(location)
                        }
                        
                        self.displayTableItems.append(dropOffLocations)
                        self.displayTableSections.append("Ballot Drop-off Locations")
                    }
                    
                    
                    if (!jsonPollingLocationsExist && !jsonEarlyVotingLocationsExist && !jsonDropOffLocationsExist) {
                        let alert = UIAlertController(title: "No Results", message: "Unfortunately, at this time it looks like there aren't any results for this location for the \(json["election"]["name"].string!). Try using a more specific address or check back soon for updates. Most locations should have information by the end of October.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    let alert = UIAlertController(title: "Not Found", message: "We couldn't find any locations with that address. Please try again with a different address.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
                self.resultsLabel.text = "Results for: \(place.formattedAddress!)"
                self.resultsLabel.isHidden = false
                
                self.displayTableView.reloadData()
                self.activityIndicator.stopAnimating()
        }
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
}

protocol SearchViewControllerDelegate: class {
    func searchViewController(_ controller: SearchViewController, didSelect location: Location)
}
