//
//  InitialViewController.swift
//  informed-voter
//
//  Created by Alex Meyer on 9/29/16.
//  Copyright © 2016 1320 Technologies. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    static let storyboardIdentifier = "InitialViewController"
    
    var stickerBrowserViewController: StickerViewController!

    @IBOutlet weak var enterAddressButton: UIButton!
    @IBOutlet weak var stickerContainerView: UIView!

    weak var delegate: InitialViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red:0.15, green:0.27, blue:0.75, alpha:1.0)

        enterAddressButton.layer.cornerRadius = 5

        stickerBrowserViewController = StickerViewController(stickerSize: .regular)
        stickerBrowserViewController.view.frame = stickerContainerView.frame
        stickerBrowserViewController.stickerBrowserView.backgroundColor = UIColor.clear

        self.addChildViewController(stickerBrowserViewController)
        stickerBrowserViewController.didMove(toParentViewController: self)
        stickerContainerView.addSubview(stickerBrowserViewController.view)

        stickerBrowserViewController.loadStickers()
        stickerBrowserViewController.stickerBrowserView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showSearchViewController(_ sender: AnyObject) {
        delegate?.initialViewControllerDidSelectSearch(self)
    }

}

protocol InitialViewControllerDelegate: class {
    func initialViewControllerDidSelectSearch(_ controller: InitialViewController)
}
