//
//  functions.swift
//  DrawBounceGame
//
//  Created by Henry Pigg on 4/15/19.
//  Copyright © 2019 Henry Pigg. All rights reserved.
//

import Foundation
import SpriteKit

func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
    let xDist = a.x - b.x
    let yDist = a.y - b.y
    return CGFloat(sqrt(xDist * xDist + yDist * yDist))
}

extension Notification.Name
{
    static let addAd = Notification.Name("addAd")
    static let noAds = Notification.Name("noAds")
    static let restorePurchases = Notification.Name("restorePurchases")
}

extension NSDate
{
    func hour() -> Int {
        let hour = Calendar.current.component(.hour, from: Date())
        
        return hour
    }
}

func playSound(sound: String, scene: SKScene) {
    
    if UserDefaults.standard.bool(forKey: "isSoundEnabled") == true {
        scene.run(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
        
    }
}

func addMusic(music: SKAudioNode, scene: SKScene) {
    if UserDefaults.standard.bool(forKey: "isMusicEnabled") == true {
        scene.addChild(music)
    }
    
}

func removeMusic(music: SKAudioNode, scene: SKScene) {
    if UserDefaults.standard.bool(forKey: "isMusicEnabled") == true {
        music.removeFromParent()
    }
}


