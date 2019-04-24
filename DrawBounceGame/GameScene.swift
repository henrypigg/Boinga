//
//  GameScene.swift
//  DrawBounceGame
//
//  Created by Henry Pigg on 1/23/19.
//  Copyright © 2019 Henry Pigg. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    
    private var ball = SKSpriteNode()
    
    private var backgroundCounter = 1
    private var parallaxBackgroundCounter = 1
    private var inkCounter:CGFloat = 0.1
    
    private var pauseMenu = SKSpriteNode()
    private var pauseButton = SKSpriteNode()
    
    private var background1 = SKSpriteNode()
    private var background2 = SKSpriteNode()
    private var parallaxBG1 = SKSpriteNode()
    private var parallaxBG2 = SKSpriteNode()
    
    private var ballWinkingFrames: [SKTexture] = []
    private var walkFrames: [SKTexture] = []
    
    private var pauseAnimation = [SKTexture]()
    let pauseAnimatedAtlas = SKTextureAtlas(named: "PauseMenu")
    var ballPositionWhenPaused = CGFloat()

    
    private var inkBar = SKShapeNode()
    
    private var pauseMenuIsOpen = false
    
    public var mainBackground = "MountainBG"
    public var parallaxBackground = "parallaxMountainBG"
    
    var pathArray = [CGPoint]()
    
    var scoreCount = SKLabelNode()
    
    let cam = SKCameraNode()
    
    
    
    
    override func didMove(to view: SKView) {
        
        let numOfImages = pauseAnimatedAtlas.textureNames.count
        for i in 1...numOfImages {
            let pauseTextureName = "Frame\(i-1)"
            pauseAnimation.append(pauseAnimatedAtlas.textureNamed(pauseTextureName))
        }
        pauseMenu = SKSpriteNode(texture: pauseAnimation[0])
        
        pauseButton.texture = SKTexture(imageNamed: "PauseButton")
        pauseButton.size = CGSize(width: 35, height: 35)
        pauseButton.position = CGPoint(x: frame.width - 45, y: frame.height - 75)
        
        background1 = SKSpriteNode(imageNamed: "main\(mainBackground)")
        background2 = SKSpriteNode(imageNamed: "main\(mainBackground)")
        parallaxBG1 = SKSpriteNode(imageNamed: "\(parallaxBackground)")
        parallaxBG2 = SKSpriteNode(imageNamed: "\(parallaxBackground)")
        
        self.camera = cam
        cam.position.y = frame.midY
        
        scoreCount = SKLabelNode(fontNamed: "Ayuthaya")
        scoreCount.zPosition = 2
        scoreCount.text = "0"
        scoreCount.fontSize = 72
        scoreCount.fontColor = .black
        scoreCount.position = CGPoint(x: frame.midX, y: self.size.height * 0.825)
        
        inkBar = SKShapeNode(rect: CGRect(x: 20, y: frame.height - 40, width: frame.width * 0.8, height: 20))
        inkBar.strokeColor = .black
        inkBar.fillColor = .black
        inkBar.zPosition = 2
        
        background1.anchorPoint = CGPoint.zero
        background2.anchorPoint = CGPoint.zero
        parallaxBG1.anchorPoint = CGPoint.zero
        parallaxBG2.anchorPoint = CGPoint.zero
        
        background1.size.height = frame.size.height
        background2.size.height = frame.size.height
        parallaxBG1.size.height = frame.size.height
        parallaxBG2.size.height = frame.size.height
        background1.size.width = frame.size.height * 0.75
        background2.size.width = frame.size.height * 0.75
        parallaxBG1.size.width = frame.size.height * 0.75
        parallaxBG2.size.width = frame.size.height * 0.75

        background1.zPosition = -1
        background2.zPosition = -1
        parallaxBG1.zPosition = -2
        parallaxBG2.zPosition = -2
        
        background1.position = CGPoint(x: 0, y: 0)
        background2.position = CGPoint(x: background1.size.width, y: 0)
        parallaxBG1.position = CGPoint(x: -parallaxBG2.size.width/2, y: 0)
        parallaxBG2.position = CGPoint(x: parallaxBG2.size.width/2, y: 0)
        
        addChild(background1)
        addChild(background2)
        addChild(parallaxBG1)
        addChild(parallaxBG2)
        
        addChild(inkBar)
        
        addChild(scoreCount)
        
        addChild(pauseButton)
        
        buildCharacter()
        animateBall()
        
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
        
        
        pathArray.removeAll()
        if physicsWorld.gravity != CGVector(dx: 0, dy: -9.8) {
            physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        }
        
        
    }
    
    
    func touchMoved(toPoint pos : CGPoint) {
        
        if(inkCounter < 6000) {
            pathArray.append(pos)
            if(pathArray.count >= 2) {
                createLine()
            }
        } else {
            print("outa ink")
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if pauseButton.contains(pos) {
            if pauseMenuIsOpen == false {
                openPauseMenu()
            } else {
                closePauseMenu()
                
            }
        }
        
    }
    
    func createLine() {
        
        let path = CGMutablePath()
        path.move(to: pathArray[0]  )
        
        for point in pathArray {
            
            path.addLine(to: point)
            
        }
        
        let line = SKShapeNode()
        line.path = path
        line.lineWidth = 5
        line.strokeColor = .black
        line.lineCap = .round
        line.physicsBody = SKPhysicsBody(edgeFrom: pathArray[pathArray.count-2], to: pathArray[pathArray.count-1])
        line.physicsBody!.restitution = 1.0
        //line.physicsBody!.friction = 0
        
        inkCounter += distance(pathArray[pathArray.count-2], pathArray[pathArray.count-1])
        
        
        
        self.addChild(line)
        
        let fade:SKAction = SKAction.fadeOut(withDuration: 1)
        fade.timingMode = .easeIn
        let remove:SKAction = SKAction.removeFromParent()
        
        line.run( SKAction.sequence( [ fade, remove ] ))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    func buildCharacter() {
        let ballAnimatedAtlas = SKTextureAtlas(named: "balls")
        
        
        let numImages = ballAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let ballTextureName = "ball\(i)"
            walkFrames.append(ballAnimatedAtlas.textureNamed(ballTextureName))
        }
        ballWinkingFrames = walkFrames
        
        let firstFrameTexture = ballWinkingFrames[0]
        ball = SKSpriteNode(texture: firstFrameTexture)
        ball.position = CGPoint(x: frame.midX, y: frame.midY + frame.midY / 2)
        ball.setScale(0.25)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: (ball.size.width / 2) * 0.888)
        ball.physicsBody!.restitution = 1.0
        ball.physicsBody!.linearDamping = 0.001
        ball.physicsBody!.angularDamping = 0.0
        ball.physicsBody!.friction = 0.0
        ball.zPosition = 0
        ball.name = "ball"
        addChild(ball)
    }
    
    
    func animateBall() {
        ball.run(SKAction.animate(with: ballWinkingFrames, timePerFrame: 0.1, resize: false, restore: true), withKey: "winkingBall")
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        //print(cam.position.x)
        if cam.position.x <= ball.position.x {
            let offset = ball.position.x - cam.position.x
            parallaxBG1.position.x += offset * 0.35
            parallaxBG2.position.x += offset * 0.35
            
            if pauseMenuIsOpen == false {
                cam.position.x = ball.position.x
            }
            
            
            //move GUI
            scoreCount.position.x = ball.position.x
            scoreCount.text = ("\(Int((ball.position.x-(frame.width/2)) / 100))")
            pauseButton.position.x = cam.position.x + frame.width / 2 - 45
        }
        //move ink bar
        inkBar.position.x = cam.position.x - frame.width / 2 + 20
        
        if inkCounter > 6000 {
            inkBar.isHidden = true
        } else {
            inkBar.xScale = 1 - inkCounter / 6000
        }
        
        //main BG scrolling
        if backgroundCounter == 1 {
            
            if background2.position.x < ball.position.x - background2.size.width / 2 {
                background1.position.x = background2.position.x + background2.size.width
                backgroundCounter = 2
            }
            
        } else if backgroundCounter == 2 {
            if background1.position.x < ball.position.x - background1.size.width / 2  {
                background2.position.x = background1.position.x + background1.size.width
                backgroundCounter = 1
            }
        }
        
        //parallax BG scrolling
        if parallaxBackgroundCounter == 1 {
            
            if parallaxBG2.position.x < ball.position.x - parallaxBG2.size.width / 2 {
                parallaxBG1.position.x = parallaxBG2.position.x + parallaxBG2.size.width
                parallaxBackgroundCounter = 2
            }
        } else if parallaxBackgroundCounter == 2 {
            if parallaxBG1.position.x < ball.position.x - parallaxBG1.size.width / 2  {
                parallaxBG2.position.x = parallaxBG1.position.x + parallaxBG1.size.width
                parallaxBackgroundCounter = 1
            }
        }
        
        //print(inkCounter)
        
        //delete ball when exits screen
        if ball.position.y < 0 {
            ball.removeFromParent()
            reset(toPoint: 0)
        }
        
        
    }
    
    func reset(toPoint: CGFloat) {
        background1.position = CGPoint(x: toPoint - background1.size.width/2, y: 0)
        background2.position = CGPoint(x: toPoint + background1.size.width/2, y: 0)
        parallaxBG1.position = CGPoint(x: toPoint - parallaxBG2.size.width/2, y: 0)
        parallaxBG2.position = CGPoint(x: toPoint + parallaxBG2.size.width/2, y: 0)
        buildCharacter()
        ball.position.x = toPoint
        cam.position.x = ball.position.x
        scoreCount.position.x = ball.position.x
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        if toPoint == 0 {
            scoreCount.text = "0"
            inkCounter = 0.1
            inkBar.isHidden = false
            inkBar.setScale(1.0)
        }
        
        
        
    }
    
    func pauseMenuInit() {
        
    }
    
    func openPauseMenu() {
        
        ballPositionWhenPaused = ball.position.x
        ball.removeFromParent()
        pauseMenuIsOpen = true
        //pauseButton.isHidden = true
        
        scoreCount.isHidden = true
        inkBar.isHidden = true
        
        background1.texture = SKTexture(imageNamed: "\(mainBackground)Blur")
        background2.texture = SKTexture(imageNamed: "\(mainBackground)Blur")
        
        pauseMenu.anchorPoint = CGPoint(x: 0, y: 0)
        pauseMenu.position = CGPoint(x: cam.position.x - frame.width/2, y: 0)
        //print("test: \(cam.position.x)")
        pauseMenu.size = frame.size
        pauseMenu.zPosition = 4
        pauseMenu.name = "pause"
        addChild(pauseMenu)
        pauseAnimation.reverse()
        
        animatePauseMenu()
        
        pauseMenu.texture = pauseAnimation[36]
    }
    
    func closePauseMenu() {
        
        reset(toPoint: ballPositionWhenPaused)
        pauseMenuIsOpen = false
        background1.texture = SKTexture(imageNamed: "main\(mainBackground)")
        background2.texture = SKTexture(imageNamed: "main\(mainBackground)")
        
        //pauseButton.isHidden = false
        ball.isHidden = false
        scoreCount.isHidden = false
        inkBar.isHidden = false
        
        pauseAnimation.reverse()
        
        pauseMenu.run(SKAction.animate(with: pauseAnimation, timePerFrame: 0.02, resize: false, restore: true)) {
            self.pauseMenu.removeFromParent()
        }
        
        
    }
    
    func animatePauseMenu() {
        pauseMenu.run(SKAction.animate(with: pauseAnimation, timePerFrame: 0.02, resize: false, restore: true), withKey: "pauseMenu")
    }
    
}
