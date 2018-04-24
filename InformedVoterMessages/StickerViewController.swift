//
//  StickerViewController.swift
//  informed-voter
//
//  Created by Alex Meyer on 10/1/16.
//  Copyright © 2016 1320 Technologies. All rights reserved.
//

import UIKit
import Messages

class StickerViewController: MSStickerBrowserViewController {
    
    var stickers = [MSSticker]()
    
    func loadStickers() {
        // Load sticker images here
        // createSticker(asset: "vote_618x618", localizedDescription: "")
    }
    
    func createSticker(asset: String, localizedDescription: String) {
        guard let stickerPath = Bundle.main.path(forResource: asset, ofType: "png") else {
            print("couldn't create the sticker path for", asset)
            return
        }
        let stickerURL = URL(fileURLWithPath: stickerPath)
        
        let sticker: MSSticker
        do {
            try sticker = MSSticker(contentsOfFileURL: stickerURL, localizedDescription: localizedDescription)
            stickers.append(sticker)
        } catch {
            print(error)
            return
        }
    }
    
    override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
        return stickers.count
    }
    
    override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
        return stickers[index]
    }
}
