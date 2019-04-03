//
//  GameViewController.swift
//  DrawBounceGame
//
//  Created by Henry Pigg on 1/23/19.
//  Copyright © 2019 Henry Pigg. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = view as? SKView {
            // Create the scene programmatically
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .resizeFill
            view.ignoresSiblingOrder = true
            //view.showsFPS = true
            //view.showsNodeCount = true
            //scene.physicsBody = SKPhysicsBody(edgeLoopFrom: scene.frame)
            scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
            view.presentScene(scene)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

