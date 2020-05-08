//
//  GameViewController.swift
//  DrawBounceGame
//
//  Created by Henry Pigg on 1/23/19.
//  Copyright © 2019 Henry Pigg. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds

class GameViewController: UIViewController, GADInterstitialDelegate {
    
    var notificationCenter = NotificationCenter.default
    
    var scene = SKScene()
    
    var interstitial: GADInterstitial!
    
    var products: [SKProduct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        IAPHandler.shared.fetchAvailableProducts()
        IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
            guard let strongSelf = self else{ return }
            if type == .purchased {
                let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                    
                })
                alertView.addAction(action)
                strongSelf.present(alertView, animated: true, completion: nil)
            }
        }
        
        interstitial = createAndLoadInterstitial()
        
        NotificationCenter.default.addObserver(self, selector: #selector(addInterstitial), name: .addAd, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(buyNoAds), name: .noAds, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(restorePurchases), name: .restorePurchases, object: nil)
        
        
        if let view = view as? SKView {
            // Create the scene programmatically
            scene = MainMenu(size: view.bounds.size)
            scene.scaleMode = .resizeFill
            view.ignoresSiblingOrder = true
            view.presentScene(scene)
        }
    }
    
    @objc func addInterstitial() {
        
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
        
    }
    
    @objc func buyNoAds() {
        IAPHandler.shared.purchaseMyProduct(index: 0)
       
    }
    
    @objc func restorePurchases() {
        IAPHandler.shared.restorePurchase()
        print("HELLOOOOO")
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        //real
        var interstitial1 = GADInterstitial(adUnitID: "ca-app-pub-8521944967344837/8582320260")
        
        //test
        //var interstitial1 = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        
        interstitial1.delegate = self
        interstitial1.load(GADRequest())
        return interstitial1
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
        
    }
}

