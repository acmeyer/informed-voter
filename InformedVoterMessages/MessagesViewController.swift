//
//  MessagesViewController.swift
//  InformedVoterMessages
//
//  Created by Alex Meyer on 9/29/16.
//  Copyright © 2016 1320 Technologies. All rights reserved.
//

import UIKit
import Messages
import GooglePlaces
import GoogleMaps

class MessagesViewController: MSMessagesAppViewController {
    
    var viewToDisplay = "initial"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Find somewhere better to place this??
        GMSPlacesClient.provideAPIKey(Constants.GOOGLE_PLACES_API_KEY)
        GMSServices.provideAPIKey(Constants.GOOGLE_MAPS_API_KEY)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
        super.willBecomeActive(with: conversation)
        
        presentViewController(for: conversation, with: presentationStyle)
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
        
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
        
        // Use this method to finalize any behaviors associated with the change in presentation style.
        guard let conversation = activeConversation else { fatalError("Expected an active conversation") }
        
        presentViewController(for: conversation, with: presentationStyle)
    }
    
    // MARK: Child view controller presentation
    func presentViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        let controller: UIViewController
        if presentationStyle == .compact {
            viewToDisplay = "initial"
            controller = instantiateInitialViewController()
        } else {
            
            if let location = Location(message: conversation.selectedMessage) {
                controller = instantiateLocationViewController(with: location)
            } else if viewToDisplay == "search" {
                controller = instantiateSearchViewController()
            } else {
                controller = instantiateInitialViewController()
            }
        }
        
        // Remove any existing child controllers
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
        
        // Embed the new controller
        addChildViewController(controller)
        
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        controller.didMove(toParentViewController: self)
    }
    
    private func instantiateSearchViewController() -> UIViewController {
        // Instantiate a `SearchViewController` and present it.
        guard let controller = storyboard?.instantiateViewController(withIdentifier: SearchViewController.storyboardIdentifier) as? SearchViewController else {
            fatalError("Unable to instantiate a SearchViewController from the storyboard")
        }
        
        controller.delegate = self
        
        return controller
    }
    
    private func instantiateInitialViewController() -> UIViewController {
        // Instantiate a `InitialViewController` and present it.
        guard let controller = storyboard?.instantiateViewController(withIdentifier: InitialViewController.storyboardIdentifier) as? InitialViewController else {
            fatalError("Unable to instantiate a InitialViewController from the storyboard")
        }
        
        controller.delegate = self
        
        return controller
    }
    
    private func instantiateLocationViewController(with location: Location) -> UIViewController {
        // Instantiate a `LocationViewController` and present it.
        guard let controller = storyboard?.instantiateViewController(withIdentifier: LocationViewController.storyboardIdentifier) as? LocationViewController else {
            fatalError("Unable to instantiate a LocationViewController from the storyboard")
        }
        
        controller.location = location
        
        return controller
    }
    
    fileprivate func composeMessage(with location: Location, caption: String, session: MSSession? = nil) -> MSMessage {
        
        let layout = MSMessageTemplateLayout()
        
        do {
            let image = try UIImage(data: NSData(contentsOf: Helpers.getGoogleStaticMapUrl(address: location.shortAddressParameter(), size: "small")) as Data)
            layout.image = image
        } catch {
            print("failed to get map image")
        }
        
        layout.imageTitle = location.name
        layout.imageSubtitle = location.shortAddressString()
        layout.caption = caption
        layout.subcaption = NSLocalizedString("Tap to view", comment: "")
        
        let message = MSMessage(session: session ?? MSSession())
        
        var mapComponents = URLComponents()
        mapComponents.scheme = "https"
        mapComponents.host = "google.com"
        mapComponents.path = "/maps/place/\(location.shortAddressParameter())"
        mapComponents.queryItems = location.queryItems
        
        message.url = mapComponents.url!
        message.layout = layout
        
        return message
    }
    
}


extension MessagesViewController: InitialViewControllerDelegate {
    func initialViewControllerDidSelectSearch(_ controller: InitialViewController) {
        viewToDisplay = "search"
        if (self.presentationStyle == .expanded) {
            guard let conversation = activeConversation else { fatalError("Expected an active conversation") }
            
            presentViewController(for: conversation, with: .expanded)
        } else {
            requestPresentationStyle(.expanded)
        }
    }
}

extension MessagesViewController: SearchViewControllerDelegate {
    func searchViewController(_ controller: SearchViewController, didSelect location: Location) {
        
        guard let conversation = activeConversation else { fatalError("Expected a conversation") }
        
        
        var messageCaption: String
        
        switch location.type {
        case "polling-location":
            messageCaption = NSLocalizedString("Here's where you can vote", comment: "")
        case "dropoff-location":
            messageCaption = NSLocalizedString("Here's where you can drop-off your ballot", comment: "")
        case "early-voting-location":
            messageCaption = NSLocalizedString("Here's where you can vote early", comment: "")
        default:
            messageCaption = NSLocalizedString("Here's where you can vote", comment: "")
        }
        
        controller.activityIndicator.startAnimating()
        
        // Create a new message with the same session as any currently selected message.
        let message = composeMessage(with: location, caption: messageCaption, session: conversation.selectedMessage?.session)
        
        // Add the message to the conversation.
        conversation.insert(message) { error in
            if let error = error {
                print(error)
            }
        }
        
        controller.activityIndicator.stopAnimating()
        dismiss()
    }
}
