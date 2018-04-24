//
//  AppDelegate.swift
//  InformedVoter
//
//  Created by Alex Meyer on 9/29/16.
//  Copyright © 2016 1320 Technologies. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Fabric
import Crashlytics
import OneSignal
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSPlacesClient.provideAPIKey(Constants.GOOGLE_PLACES_API_KEY)
        GMSServices.provideAPIKey(Constants.GOOGLE_MAPS_API_KEY)
        Fabric.with([Crashlytics.self])
        OneSignal.initWithLaunchOptions(launchOptions, appId: Constants.ONESIGNAL_APP_ID)
        
        // Overrides for autocomplete
        UIActivityIndicatorView.appearance().color = UIColor.white
        
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = UIColor(red:0.15, green:0.27, blue:0.75, alpha:1.0)
        
        UISearchBar.appearance().searchBarStyle = UISearchBarStyle.minimal
        UISearchBar.appearance().tintColor = UIColor.lightText
        
        
        // Color of typed text in the search bar.
        let searchBarTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: UIFont.systemFontSize)]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = searchBarTextAttributes
        
        // Color of the placeholder text in the search bar prior to text entry.
        let placeholderAttributes = [NSForegroundColorAttributeName: UIColor.lightText, NSFontAttributeName: UIFont.systemFont(ofSize: UIFont.systemFontSize)]
        
        // Color of the default search text.
        // NOTE: In a production scenario, "Search" would be a localized string.
        let attributedPlaceholder = NSAttributedString(string: "Enter Address", attributes: placeholderAttributes)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = attributedPlaceholder
        
        
        // Set default HUD
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        SVProgressHUD.setMinimumDismissTimeInterval(1.0)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        let urlHost = url.host as String!
        if (urlHost == "directions") {
            guard let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: false), let queryItems = urlComponents.queryItems else { return false }
            
            if let location = Location(queryItems: queryItems) {
                if (application.canOpenURL(URL(string:"comgooglemaps://")!)) {
                    application.open(Helpers.getGoogleMapUrl(address: location.shortAddressParameter()), options: [:], completionHandler: nil)
                    Answers.logCustomEvent(withName: "Show directions map from iMessage", customAttributes: ["map":"google"])
                } else {
                    application.open(Helpers.getAppleMapUrl(address: location.shortAddressParameter()), options: [:], completionHandler: nil)
                    Answers.logCustomEvent(withName: "Show directions map from iMessage", customAttributes: ["map":"apple"])
                }
            }
        }
        
        return true
    }


}

