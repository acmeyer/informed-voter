//
//  MainSearchViewController.swift
//  informed-voter
//
//  Created by Alex Meyer on 9/29/16.
//  Copyright © 2016 1320 Technologies. All rights reserved.
//

import UIKit
import Crashlytics
import Alamofire
import SwiftyJSON
import GooglePlaces

class MainSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    static let storyboardIdentifier = "mainSearchViewController"

    var focusKeyboard = false

    var displayTableSections = [String]()
    var displayTableItems = [[Location]]()

    lazy var searchBar = UISearchBar(frame: CGRect.zero)

    var place: GMSPlace?

    @IBOutlet weak var displayTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var useMessagesAppButton: UIButton!
    @IBOutlet weak var resultsLabel: UILabel!

    @IBOutlet weak var initialView: UIView!
    @IBOutlet weak var findInfoButton: UIButton!
    @IBOutlet weak var useiMessageButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.tintColor = UIColor(red:1.0, green:0.35, blue:0.41, alpha:1.0)
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.isTranslucent = false

        useMessagesAppButton.layer.cornerRadius = 5

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        if place != nil {
            initialView.isHidden = true
            loadDisplayTable()

            searchBar.placeholder = "Enter Address"
            self.navigationItem.titleView = searchBar

            searchBar.delegate = self
        }

        if let indexPath = displayTableView.indexPathForSelectedRow {
            displayTableView.deselectRow(at: indexPath, animated: true)
            focusKeyboard = false
        }
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        showAutocompleteModal()

        return false
    }

    // UI
    func setupUI() {
        self.view.backgroundColor = UIColor(red:0.15, green:0.27, blue:0.75, alpha:1.0)

        findInfoButton.layer.cornerRadius = 5
        useiMessageButton.layer.cornerRadius = 5

        initialView.backgroundColor = UIColor(red:0.15, green:0.27, blue:0.75, alpha:1.0)

        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        // Sets shadow (line below the bar) to a blank image
        self.navigationController?.navigationBar.shadowImage = UIImage()
        // Sets the translucent background color
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 64.0, green: 134.0, blue: 215.0, alpha: 0.0)
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        self.navigationController?.navigationBar.isTranslucent = true

        displayTableView.delegate = self
        displayTableView.dataSource = self

        displayTableView.backgroundColor = UIColor.clear
    }

    func loadDisplayTable() {

        activityIndicator.startAnimating()

        let address = place!.formattedAddress!.replacingOccurrences(of: " ", with: "+").replacingOccurrences(of: ",", with: "")
        let url = "\(Constants.VOTER_API)?address=\(address)&electionId=\(Constants.ELECTION_ID)&key=\(Constants.GOOGLE_PLACES_API_KEY)"

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
                        let alert = UIAlertController(title: "No Results", message: "Unfortunately, we couldn't find any election information for \(self.place!.formattedAddress!) for the \(json["election"]["name"].string!). Please check to make sure you entered it correctly, try using a more specific address, or check back again closer to Election Day. Most locations should have information 2-4 weeks prior to the election. You can also always consult your local election official for the most up to date information.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        Answers.logCustomEvent(withName: "No information for address", customAttributes: ["address":self.place!.formattedAddress!])

                        self.navigationItem.rightBarButtonItem = nil
                    }

                case .failure(let error):
                    print(error.localizedDescription)
                    let alert = UIAlertController(title: "Not Found", message: "Unfortunately, we couldn't find any election information for that address. Please check to make sure you entered it correctly, try using a more specific address, or check back again closer to Election Day. Most locations should have information 2-4 weeks prior to the election. You can also always consult your local election official for the most up to date information.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }

                self.resultsLabel.text = "Results for: \(self.place!.formattedAddress!)"
                self.resultsLabel.isHidden = false

                Answers.logContentView(withName: "Polling information results", contentType: "List", contentId: self.place!.formattedAddress!)

                self.displayTableView.reloadData()
                self.activityIndicator.stopAnimating()
        }
    }


    @IBAction func useiMessageButtonPressed(_ sender: AnyObject) {
        Answers.logCustomEvent(withName: "Use iMessage app button pressed", customAttributes: ["source":"initial view"])

        UIApplication.shared.open(URL(string: "https://itunes.apple.com/app/id1161838912?app=messages")!, options: [:], completionHandler: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Table Delegate
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

    func showAutocompleteModal() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self

        autocompleteController.tableCellBackgroundColor = UIColor(red:0.15, green:0.27, blue:0.75, alpha:1.0)
        autocompleteController.primaryTextColor = UIColor.white
        autocompleteController.primaryTextHighlightColor = UIColor.lightText
        autocompleteController.secondaryTextColor = UIColor.lightText
        autocompleteController.tableCellSeparatorColor = UIColor.lightText

        self.present(autocompleteController, animated: true, completion: nil)
    }

    @IBAction func getInfoButtonPressed(_ sender: AnyObject) {
        Answers.logCustomEvent(withName: "Show search button pressed", customAttributes: ["source":"initial view"])

        showAutocompleteModal()
    }

    @IBAction func useMessagesAppButtonPressed(_ sender: AnyObject) {
        Answers.logCustomEvent(withName: "Use iMessage app button pressed", customAttributes: ["source":"search list view"])

        UIApplication.shared.open(URL(string: "https://itunes.apple.com/app/id1161838912?app=messages")!, options: [:], completionHandler: nil)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showLocationViewSegue") {
            let nextVC = segue.destination as! MainLocationViewController
            let selectedIndexPath = displayTableView.indexPathForSelectedRow
            nextVC.location = displayTableItems[(selectedIndexPath?.section)!][(selectedIndexPath?.row)!]

            Answers.logCustomEvent(withName: "Selected location cell")
        }
    }

}

extension MainSearchViewController: GMSAutocompleteViewControllerDelegate {

    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith result: GMSPlace) {
        place = result
        self.dismiss(animated: true, completion: nil)
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }

    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }

}
