//
//  GameIntroScene.swift
//  DrawBounceGame
//
//  Created by Andrew Harker on 4/30/19.
//  Copyright © 2019 Henry Pigg. All rights reserved.
//

import Foundation
import SpriteKit

class GameIntroScene: SKScene {
    let background = SKSpriteNode(imageNamed: "boingaMenuFake")
    
    override func didMove(to view: SKView) {
        background.zPosition = -1
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(background)
    }
    
    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneTapped()
    }
    #else
    override func mouseDown(with theEvent: NSEvent) {
        sceneTapped()
    }
    
    #endif
    
    func sceneTapped() {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        
        let transition = SKTransition.doorway(withDuration: 1.5)
        view?.presentScene(gameScene, transition: transition)
    }
}
