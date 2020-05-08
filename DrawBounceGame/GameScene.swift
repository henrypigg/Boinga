//
//  GameScene.swift
//  DrawBounceGame
//
//  Created by Henry Pigg on 1/23/19.
//  Copyright © 2019 Henry Pigg. All rights reserved.
//


import SpriteKit
import GameplayKit
import UIKit
import GoogleMobileAds


class GameScene: SKScene, SKPhysicsContactDelegate, GADInterstitialDelegate {
    
    
    var ball = SKSpriteNode()
    
    var currentInkColor = UIColor()
    
    var isUnlimitedInkOn = false
    
    var isInkIndicatorVisible = false
    
    var backgroundCounter = 1
    var parallaxBackgroundCounter = 1
    var inkCounter:CGFloat = 0.1
    
    var totalInk = 3000
    
    var unlimitedInk = false
    
    var deathMenu = SKSpriteNode()
    
    var pauseMenu = SKSpriteNode()
    var pauseButton = SKSpriteNode()
    
    var mainMenuButton = SKSpriteNode()
    var continueButton = SKSpriteNode()
    var restartButton = SKSpriteNode()
    var settingsButton = SKSpriteNode()
    var rateButton = SKSpriteNode(imageNamed: "RateButton")
    var noAdsButton = SKSpriteNode(imageNamed: "NoAds")
    
    var pauseCurrentScore = SKLabelNode()
    var pauseHighScore = SKLabelNode()
    
    var background1 = SKSpriteNode()
    var background2 = SKSpriteNode()
    var parallaxBG1 = SKSpriteNode()
    var parallaxBG2 = SKSpriteNode()
    
    var inkPack = SKSpriteNode()
    
    var ballWinkingFrames: [SKTexture] = []
    var walkFrames: [SKTexture] = []
    
    var pauseAnimation = [SKTexture]()
    let pauseAnimatedAtlas = SKTextureAtlas(named: "PauseMenu")
    var ballPositionWhenPaused = CGFloat()
    
    var deathMenuAnimation = [SKTexture]()
    let deathAnimatedAtlas = SKTextureAtlas(named: "DeathMenu")
    var isDeathMenuOpen = false
    
    var inkBar = SKShapeNode()
    
    var pauseMenuIsOpen = false
    
    var mainBackground = String()
    var parallaxBackground = String()
    
    var pathArray = [CGPoint]()
    
    var scoreCount = SKLabelNode()
    var playerScore = Int()
    
    var deathCoinLabel = SKLabelNode()
    
    let cam = SKCameraNode()
    
    let ballCategory:UInt32    = 0x1 << 0 //1
    let lineCategory:UInt32    = 0x1 << 1 //2
    let inkPackCategory:UInt32 = 0x1 << 2 //4
    
    var inkIndicator = SKSpriteNode()
    
    var adCounter = 1
    
    var mainViewController = GameViewController()
    
    
    //sound and music
    var gameMusic = SKAudioNode()
    var bounceSound = SKAudioNode()
    var currentGameMusic = 1
    
    // One use bool tests
    var isTouchDownTrue = false
    var shouldRunPauseAnimation = true
    var areAnimationsDone = false
    
    let notificationCenter = NotificationCenter.default
    
    // button presses
    var pauseButtonPress = false
    var continueButtonPress = false
    var restartButtonPress = false
    var mainMenuButtonPress = false
    var settingsButtonPress = false
    
    // button update calls
    var continueButtonUpdate = false
    var restartButtonUpdate = false
    var playAgainButtonUpdate = false
    var pauseMainMenuButtonUpdate = false
    var deathMainMenuButtonUpdate = false
    var settingsButtonUpdate = false
    
    override func didMove(to view: SKView) {
        
        
        //initialize ad
        
        
        
        isUnlimitedInkOn = UserDefaults.standard.bool(forKey: "isUnlimitedInkOn")
        
        
        gameMusic = SKAudioNode(fileNamed: "MainMusic1")
        
        let currentBG = UserDefaults.standard.string(forKey: "currentBackground")
        
        setCurrentInkColor()
        
        mainBackground = currentBG!
        parallaxBackground = "parallax\(currentBG!)"
        
        self.physicsWorld.contactDelegate = self
        
        notificationCenter.addObserver(self, selector: #selector(appMovedCameBack), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
        
        let numOfImages = pauseAnimatedAtlas.textureNames.count
        for i in 1...numOfImages {
            let pauseTextureName = "Frame\(i-1)"
            pauseAnimation.append(pauseAnimatedAtlas.textureNamed(pauseTextureName))
        }
        pauseMenu = SKSpriteNode(texture: pauseAnimation[0])
        
        let numOfImages2 = deathAnimatedAtlas.textureNames.count
        for i in 1...numOfImages2 {
            let deathTextureName = "DeathMenu\(i)"
            deathMenuAnimation.append(deathAnimatedAtlas.textureNamed(deathTextureName))
        }
        deathMenu = SKSpriteNode(texture: deathMenuAnimation[0])
        
        pauseButton.texture = SKTexture(imageNamed: "PauseButton")
        pauseButton.size = CGSize(width: 35, height: 35)
        pauseButton.position = CGPoint(x: frame.width - 45, y: frame.height - 75)
        
        background1 = SKSpriteNode(imageNamed: "main\(mainBackground)")
        background2 = SKSpriteNode(imageNamed: "main\(mainBackground)")
        parallaxBG1 = SKSpriteNode(imageNamed: "\(parallaxBackground)")
        parallaxBG2 = SKSpriteNode(imageNamed: "\(parallaxBackground)")
        
        inkIndicator = SKSpriteNode(imageNamed: "DottedArrow")
        //inkIndicator.position = CGPoint(x: 0, y: 0)
        inkIndicator.size = CGSize(width: frame.width * (200/1600), height: frame.height * (100/2710))
        inkIndicator.zPosition = 1
        
        
        self.camera = cam
        cam.position.y = frame.midY
        
        scoreCount = SKLabelNode(fontNamed: "Avenir Next Regular")
        scoreCount.zPosition = 2
        scoreCount.text = "0"
        scoreCount.fontSize = 60
        scoreCount.fontColor = .black
        scoreCount.position = CGPoint(x: frame.midX, y: self.size.height * 0.85)
        
        inkBar = SKShapeNode(rect: CGRect(x: 20, y: frame.height - 35, width: frame.width * 0.8, height:15))
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
        
        inkPack = SKSpriteNode(imageNamed: "inkPack")
        inkPack.position = CGPoint(x: 4000, y: Int.random(in: Int((frame.size.height * 0.5)) ... Int((frame.size.height * 0.8))))
        inkPack.size = CGSize(width: 96, height: 96)
        inkPack.zPosition = 0
        inkPack.name = "inkPack"
        inkPack.physicsBody = SKPhysicsBody(circleOfRadius: (inkPack.size.width / 2) * 0.888)
        inkPack.physicsBody?.affectedByGravity = false
        inkPack.physicsBody?.isDynamic = false
        inkPack.physicsBody?.categoryBitMask = inkPackCategory
        inkPack.physicsBody?.contactTestBitMask = ballCategory
        
        addChild(inkPack)
        
        addChild(background1)
        addChild(background2)
        addChild(parallaxBG1)
        addChild(parallaxBG2)
        
        addChild(inkBar)
        
        addChild(scoreCount)
        
        addChild(pauseButton)
        
        addMusic(music: gameMusic, scene: self)
        
        
        buildCharacter()
        animateBall()
        
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision:UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == lineCategory | ballCategory {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            playSound(sound: "BoingSound", scene: self)
            
            childNode(withName: "line")?.removeFromParent()
            
            
        }
        if collision == inkPackCategory | ballCategory {
            print("hello")
            animateBall()
            
            if inkCounter - 1000 > 0 {
                inkCounter -= 1000
            } else {
                inkCounter = 0.1
            }
            inkBar.isHidden = false
            inkPack.position = CGPoint(x: inkPack.position.x + 4000, y: CGFloat(Int.random(in: Int((frame.size.height * 0.2)) ... Int((frame.size.height * 0.7)))))
            inkPack.removeFromParent()
            addChild(inkPack)
        }
    }
    
    @objc func appMovedCameBack() {
        print("App Came Back!")
        if playerScore > 0 && pauseMenuIsOpen == false && isDeathMenuOpen == false{
            shouldRunPauseAnimation = false
            openPauseMenu()
            shouldRunPauseAnimation = true
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
        
        isTouchDownTrue = true
        
        if physicsWorld.gravity != CGVector(dx: 0, dy: -9.8) && pauseMenuIsOpen == false && isDeathMenuOpen == false {
            physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
            gameMusic.run(SKAction.play())
            
        }
        
        if pauseButton.contains(pos) && pauseMenuIsOpen == false && ball.position.y > 0 {
            physicsWorld.gravity = CGVector(dx: 0, dy: 0)
            pauseButtonPress = true
        }
        
        if continueButton.contains(pos) && pauseMenuIsOpen == true && areAnimationsDone == true {
            print("CONTINUE")
            areAnimationsDone = false
            continueButtonPress = true
            continueButton.run(SKAction.setTexture(SKTexture(imageNamed: "ContinueLight")))
        }
        
        if restartButton.contains(pos) && pauseMenuIsOpen == true && areAnimationsDone == true {
            areAnimationsDone = false
            restartButtonPress = true
            restartButton.run(SKAction.setTexture(SKTexture(imageNamed: "RestartLight")))
        } else if restartButton.contains(pos) && isDeathMenuOpen == true && areAnimationsDone == true {
            print("RESTARTING")
            areAnimationsDone = false
            restartButtonPress = true
            restartButton.run(SKAction.setTexture(SKTexture(imageNamed: "PlayAgainLight")))
        }
        
        if mainMenuButton.contains(pos) && areAnimationsDone == true {
            areAnimationsDone = false
            mainMenuButtonPress = true
            print("Hello?")
            mainMenuButton.run(SKAction.setTexture(SKTexture(imageNamed: "MainMenuLight")))
        }
        
        if settingsButton.contains(pos) && areAnimationsDone == true {
            areAnimationsDone = false
            settingsButtonPress = true
            
            settingsButton.run(SKAction.setTexture(SKTexture(imageNamed: "SettingsLight")))
        }
        
        if rateButton.contains(pos) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            playSound(sound: "clickSound", scene: self)
            
            if #available( iOS 10.3,*){
                SKStoreReviewController.requestReview()
            }
        }
        
        if noAdsButton.contains(pos) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            NotificationCenter.default.post(name: .noAds, object: nil)
        }
        
        pathArray.removeAll()
        
        
    }
    
    
    func touchMoved(toPoint pos : CGPoint) {
        
        if(isTouchDownTrue == true && pauseButton.contains(pos) == false && (inkCounter < CGFloat(totalInk) || isUnlimitedInkOn == true) && pauseMenuIsOpen == false && isDeathMenuOpen == false) {
            pathArray.append(pos)
            if(pathArray.count >= 2) {
                createLine()
            }
        }
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
        isTouchDownTrue = false
        
        if continueButtonPress == true {
            continueButtonPress = false
            continueButtonUpdate = true
        }
        
        if restartButtonPress == true && pauseMenuIsOpen == true {
            restartButtonPress = false
            restartButtonUpdate = true
            
        } else if restartButtonPress == true && isDeathMenuOpen == true {
            restartButtonPress = false
            playAgainButtonUpdate = true
        }
        
        if mainMenuButtonPress == true && pauseMenuIsOpen == true {
            mainMenuButtonPress = false
            pauseMainMenuButtonUpdate = true
            
        } else if mainMenuButtonPress == true && isDeathMenuOpen == true {
            mainMenuButtonPress = false
            deathMainMenuButtonUpdate = true
        }
        
        if settingsButtonPress == true && isDeathMenuOpen == true {
            settingsButtonPress = false
            settingsButtonUpdate = true
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
        line.strokeColor = currentInkColor
        line.lineCap = .round
        line.glowWidth = 2
        line.physicsBody = SKPhysicsBody(edgeFrom: pathArray[pathArray.count-2], to: pathArray[pathArray.count-1])
        line.physicsBody!.restitution = 1.0
        line.physicsBody!.linearDamping = 0
        line.physicsBody?.categoryBitMask = lineCategory
        line.physicsBody?.contactTestBitMask = ballCategory
        line.physicsBody!.friction = 0
        line.name = "line"
        
        inkCounter += distance(pathArray[pathArray.count-2], pathArray[pathArray.count-1])
        
        
        
        self.addChild(line)
        
        let fade:SKAction = SKAction.fadeOut(withDuration: 3)
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
        ball.physicsBody!.linearDamping = 0.1
        //ball.physicsBody!.angularDamping = 0.1
        ball.physicsBody!.friction = 0
        ball.physicsBody?.categoryBitMask = ballCategory
        ball.physicsBody?.collisionBitMask = lineCategory
        ball.physicsBody?.contactTestBitMask = inkPackCategory
        ball.zPosition = 0
        ball.name = "ball"
        addChild(ball)
    }
    
    
    func animateBall() {
        ball.run(SKAction.animate(with: ballWinkingFrames, timePerFrame: 0.1, resize: false, restore: true), withKey: "winkingBall")
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if cam.position.x <= ball.position.x {
            let offset = ball.position.x - cam.position.x
            parallaxBG1.position.x += offset * 0.35
            parallaxBG2.position.x += offset * 0.35
            
            if pauseMenuIsOpen == false {
                cam.position.x = ball.position.x
            }
            
            
            
            //move GUI
            scoreCount.position.x = ball.position.x
            playerScore = Int((ball.position.x-(frame.width/2)) / 100)
            scoreCount.text = ("\(playerScore)")
            inkIndicator.position.x = ball.position.x + (frame.width / 2 * (1390/1600))
            
            
            if UserDefaults.standard.integer(forKey: "highScore") < playerScore {
                UserDefaults.standard.set(playerScore, forKey: "highScore")
            }
            
            pauseButton.position.x = cam.position.x + frame.width / 2 - 45
        }
        //move ink bar
        inkBar.position.x = cam.position.x - frame.width / 2 + 20
        
        if inkCounter > CGFloat(totalInk) {
            inkBar.isHidden = true
        } else {
            inkBar.xScale = 1 - inkCounter / CGFloat(totalInk)
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
        //move inkPack when it exits screen
        if inkPack.position.x < cam.position.x - frame.size.width {
            inkPack.position = CGPoint(x: inkPack.position.x + 4000, y: CGFloat(Int.random(in: Int((frame.size.height * 0.2)) ... Int((frame.size.height * 0.7)))))
            inkPack.removeFromParent()
            addChild(inkPack)
        }
        
        if inkPack.position.x - ball.position.x < 1000 && isInkIndicatorVisible == false {
            isInkIndicatorVisible = true
            inkIndicator.position.y = inkPack.position.y
            addChild(inkIndicator)
            print("helloo")
        }
        
        if inkIndicator.position.x > inkPack.position.x && isInkIndicatorVisible == true {
            isInkIndicatorVisible = false
            inkIndicator.removeFromParent()
        }
        
        //delete ball when exits screen
        if ball.position.y < -64 {
            if isDeathMenuOpen == false {
                
                isDeathMenuOpen = true
                openDeathMenu()
            }
            
        } else if pauseButtonPress == true {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            playSound(sound: "clickSound", scene: self)
            openPauseMenu()
            pauseButtonPress = false
        }
        if continueButtonUpdate == true {
            continueButtonUpdate = false
            continueButton.run(SKAction.setTexture(SKTexture(imageNamed: "Continue")))
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            playSound(sound: "clickSound", scene: self)
            closePauseMenu(shouldReset: false)
            
        } else if restartButtonUpdate == true {
            restartButtonUpdate = false
            restartButton.run(SKAction.setTexture(SKTexture(imageNamed: "Restart")))
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            playSound(sound: "clickSound", scene: self)
            closePauseMenu(shouldReset: true)
        } else if playAgainButtonUpdate == true {
            playAgainButtonUpdate = false
            restartButton.run(SKAction.setTexture(SKTexture(imageNamed: "PlayAgain")))
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            playSound(sound: "clickSound", scene: self)
            closeDeathMenu()
            print("updatewoo")
        } else if pauseMainMenuButtonUpdate == true {
            pauseMainMenuButtonUpdate = false
            mainMenuButton.run(SKAction.setTexture(SKTexture(imageNamed: "MainMenu")))
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            playSound(sound: "clickSound", scene: self)
            closePauseMenu(shouldReset: true)
            goToMainMenu()
        } else if deathMainMenuButtonUpdate == true {
            deathMainMenuButtonUpdate = false
            mainMenuButton.run(SKAction.setTexture(SKTexture(imageNamed: "MainMenu")))
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            playSound(sound: "clickSound", scene: self)
            closeDeathMenu()
            goToMainMenu()
        } else if settingsButtonUpdate == true {
            
            MyVariables.settingsSender = 1
            
            settingsButtonUpdate = false
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            playSound(sound: "clickSound", scene: self)
            settingsButton.run(SKAction.setTexture(SKTexture(imageNamed: "Settings")))
            
            //Open Settings
            loadSettings()
        }
        
        
        //change Music
        if playerScore > 200 && currentGameMusic != 2 {
            removeMusic(music: gameMusic, scene: self)
            gameMusic = SKAudioNode(fileNamed: "MainMusic2")
            addMusic(music: gameMusic, scene: self)
            currentGameMusic = 2
        }
        
        //button Presses
        
        
        
    }
    
    func reset(toPoint: CGFloat) {
        isTouchDownTrue = false
        pathArray.removeAll()
        
        buildCharacter()
        
        if toPoint == 0 {
            removeMusic(music: gameMusic, scene: self)
            gameMusic = SKAudioNode(fileNamed: "MainMusic1")
            addMusic(music: gameMusic, scene: self)
            currentGameMusic = 1
            
            totalInk = 3000
            inkPack.position.x = 2000
            scoreCount.text = "0"
            inkCounter = 0.1
            inkBar.isHidden = false
            inkBar.setScale(1.0)
            ball.position.x = frame.width/2
            background1.position = CGPoint(x: toPoint - background1.size.width/2, y: 0)
            background2.position = CGPoint(x: toPoint + background1.size.width/2, y: 0)
            parallaxBG1.position = CGPoint(x: toPoint - parallaxBG2.size.width/2, y: 0)
            parallaxBG2.position = CGPoint(x: toPoint + parallaxBG2.size.width/2, y: 0)
        } else {
            ball.position.x = toPoint
        }
        
        cam.position.x = ball.position.x
        scoreCount.position.x = ball.position.x
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        
    }
    
    func openPauseMenu() {
        gameMusic.run(SKAction.pause())
        
        pauseMenuIsOpen = true
        ball.removeFromParent()
        pauseButton.isHidden = true
        ballPositionWhenPaused = cam.position.x
        
        //pauseButton.isHidden = true
        scoreCount.isHidden = true
        inkBar.isHidden = true
        
        background1.texture = SKTexture(imageNamed: "\(mainBackground)Blur")
        background2.texture = SKTexture(imageNamed: "\(mainBackground)Blur")
        
        pauseMenu.anchorPoint = CGPoint(x: 0, y: 0)
        pauseMenu.position = CGPoint(x: cam.position.x - frame.width/2, y: 0)
        pauseMenu.size = frame.size
        pauseMenu.zPosition = 4
        pauseMenu.name = "pause"
        
        continueButton = SKSpriteNode(imageNamed: "Continue")
        continueButton.position = CGPoint(x: cam.position.x, y: frame.height * 1350 / 2714)
        continueButton.size = CGSize(width: frame.width * 0.4988, height: frame.height * 0.0689)
        continueButton.zPosition = 5
        
        restartButton = SKSpriteNode(imageNamed: "Restart")
        restartButton.position = CGPoint(x: cam.position.x, y: frame.height * 0.3965)
        restartButton.size = CGSize(width: frame.width * 0.4988, height: frame.height * 0.0689)
        restartButton.zPosition = 5
        
        mainMenuButton = SKSpriteNode(imageNamed: "MainMenu")
        mainMenuButton.position = CGPoint(x: cam.position.x, y: frame.height * 805 / 2714)
        mainMenuButton.size = CGSize(width: frame.width * 0.4988, height: frame.height * 0.0689)
        mainMenuButton.zPosition = 5
        
        rateButton.size = CGSize(width: frame.size.width * (215/1604), height: frame.size.height * (215/2714))
        rateButton.position = CGPoint(x: cam.position.x - frame.size.width/2 + (frame.size.width * (365/1604)), y: frame.size.height * (305/2714))
        rateButton.zPosition = 5
        
        noAdsButton.size = CGSize(width: frame.size.width * (215/1604), height: frame.size.height * (215/2714))
        noAdsButton.position = CGPoint(x: cam.position.x - frame.size.width/2 + (frame.size.width * (1239/1604)), y: frame.size.height * (305/2714))
        noAdsButton.zPosition = 5
        
        pauseCurrentScore = SKLabelNode(fontNamed: "Avenir Next Regular")
        pauseCurrentScore.zPosition = 5
        pauseCurrentScore.text = scoreCount.text
        pauseCurrentScore.fontSize = 72
        pauseCurrentScore.fontColor = .black
        pauseCurrentScore.position = CGPoint(x: cam.position.x, y: frame.height * 0.6817)
        
        pauseHighScore = SKLabelNode(fontNamed: "Avenir Next Regular")
        pauseHighScore.zPosition = 5
        pauseHighScore.text = ("\(UserDefaults.standard.integer(forKey: "highScore"))")
        pauseHighScore.fontSize = 36
        pauseHighScore.fontColor = .black
        pauseHighScore.position = CGPoint(x: cam.position.x, y: frame.height * 0.591)
        
        addChild(pauseMenu)
        pauseAnimation.reverse()
        
        if shouldRunPauseAnimation == true {
            animatePauseMenu()
        } else {
            addChild(pauseCurrentScore)
            addChild(restartButton)
            addChild(mainMenuButton)
            addChild(continueButton)
            addChild(pauseHighScore)
            addChild(rateButton)
            addChild(noAdsButton)
            areAnimationsDone = true
            
            
        }
        
        pauseMenu.texture = pauseAnimation[36]
        
    }
    
    func closePauseMenu(shouldReset: Bool) {
        areAnimationsDone = false
        background1.texture = SKTexture(imageNamed: "main\(self.mainBackground)")
        background2.texture = SKTexture(imageNamed: "main\(self.mainBackground)")
        parallaxBG1.position = CGPoint(x: ballPositionWhenPaused - parallaxBG2.size.width/2, y: 0)
        parallaxBG2.position = CGPoint(x: ballPositionWhenPaused + parallaxBG2.size.width/2, y: 0)
        
        if shouldReset == true {
            self.reset(toPoint: 0)
        } else {
            self.reset(toPoint: self.ballPositionWhenPaused)
        }
        pauseMenu.position.x = cam.position.x - frame.size.width / 2
        
        pauseAnimation.reverse()
        
        pauseMenu.run(SKAction.animate(with: pauseAnimation, timePerFrame: 0.02, resize: false, restore: true), completion: {
            self.pauseMenu.removeFromParent()
            
            self.pauseMenuIsOpen = false
            
            //pauseButton.isHidden = false
            self.ball.isHidden = false
            self.scoreCount.isHidden = false
            self.inkBar.isHidden = false
            self.pauseButton.isHidden = false
            
        })
        
        
        continueButton.removeFromParent()
        restartButton.removeFromParent()
        mainMenuButton.removeFromParent()
        rateButton.removeFromParent()
        noAdsButton.removeFromParent()
        
        pauseCurrentScore.removeFromParent()
        pauseHighScore.removeFromParent()
        
        
        
    }
    
    func animatePauseMenu() {
        pauseMenu.run(SKAction.animate(with: pauseAnimation, timePerFrame: 0.02, resize: false, restore: true)) {
            self.addChild(self.pauseCurrentScore)
            self.addChild(self.restartButton)
            self.addChild(self.continueButton)
            self.addChild(self.rateButton)
            self.addChild(self.noAdsButton)
            self.addChild(self.pauseHighScore)
            self.addChild(self.mainMenuButton)
            self.areAnimationsDone = true
        }
    }
    
    func goToMainMenu() {
        let mainMenu = MainMenu(size: size)
        mainMenu.scaleMode = scaleMode
        mainMenu.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        let transition = SKTransition.crossFade(withDuration: 0.5)
        view?.presentScene(mainMenu, transition: transition)
    }
    
    func openDeathMenu() {
        print("OPENING DEATH MENU")

        
        gameMusic.run(SKAction.stop())
        
        let newCoinValue = UserDefaults.standard.integer(forKey: "coins") + Int(Double(playerScore * playerScore) * 0.002)
        
        inkIndicator.removeFromParent()
        ball.removeFromParent()
        pauseButton.isHidden = true
        scoreCount.isHidden = true
        inkBar.isHidden = true
        
        background1.texture = SKTexture(imageNamed: "\(mainBackground)Blur")
        background2.texture = SKTexture(imageNamed: "\(mainBackground)Blur")
        
        deathMenu.anchorPoint = CGPoint(x: 0, y: 0)
        deathMenu.position = CGPoint(x: cam.position.x - frame.width/2, y: 0)
        deathMenu.size = frame.size
        deathMenu.zPosition = 4
        deathMenu.name = "death"
        
        restartButton = SKSpriteNode(imageNamed: "PlayAgain")
        restartButton.position = CGPoint(x: cam.position.x, y: frame.height * (1020/2710))
        restartButton.size = CGSize(width: frame.width * (1053/1600), height: frame.height * (222/2710))
        restartButton.zPosition = 5
        
        mainMenuButton = SKSpriteNode(imageNamed: "MainMenu")
        mainMenuButton.position = CGPoint(x: cam.position.x, y: frame.height * 692 / 2710)
        mainMenuButton.size = CGSize(width: frame.width * (1053/1600), height: frame.height * (222/2710))
        mainMenuButton.zPosition = 5
        
        settingsButton = SKSpriteNode(imageNamed: "Settings")
        settingsButton.position = CGPoint(x: cam.position.x, y: frame.height * 364 / 2710)
        settingsButton.size = CGSize(width: frame.width * (1053/1600), height: frame.height * (222/2710))
        settingsButton.zPosition = 5
        
        pauseCurrentScore = SKLabelNode(fontNamed: "Avenir Next Ultra Light")
        pauseCurrentScore.zPosition = 5
        pauseCurrentScore.text = scoreCount.text
        pauseCurrentScore.fontSize = 72
        pauseCurrentScore.fontColor = .black
        pauseCurrentScore.position = CGPoint(x: cam.position.x, y: frame.height * (1886/2710))
        
        pauseHighScore = SKLabelNode(fontNamed: "Avenir Next Regular")
        pauseHighScore.zPosition = 5
        pauseHighScore.text = ("\(UserDefaults.standard.integer(forKey: "highScore"))")
        pauseHighScore.fontSize = 36
        pauseHighScore.fontColor = .black
        pauseHighScore.position = CGPoint(x: cam.position.x, y: frame.height * 1600/2710)
        
        deathCoinLabel = SKLabelNode(fontNamed: "Avenir Next Ultra Light")
        deathCoinLabel.zPosition = 5
        deathCoinLabel.text = ("\(0)")
        deathCoinLabel.fontSize = 96
        deathCoinLabel.fontColor = .black
        deathCoinLabel.position = CGPoint(x: cam.position.x, y: frame.height * 1175/2710)
        
        addChild(deathMenu)
        deathMenuAnimation.reverse()
        animateDeathMenu()
        deathMenu.texture = deathMenuAnimation[4]
        
        //count the coins
        
        let oldCoinValue = UserDefaults.standard.integer(forKey: "coins")
        
        UserDefaults.standard.set(newCoinValue, forKey: "coins")
        
        var coinCounter = 0
        let wait = SKAction.wait(forDuration: 2.0 / Double(newCoinValue - oldCoinValue))
        let block = SKAction.run {
            if coinCounter < (newCoinValue - oldCoinValue) {
                coinCounter += 1
                self.deathCoinLabel.text = ("\(coinCounter)")
            } else {
                self.removeAction(forKey: "coinCounter")
                
                
            }
        }
        
        run(SKAction.repeatForever(SKAction.sequence([wait,block])), withKey: "coinCounter")
        
        
        
    }
    
    func animateDeathMenu() {
        deathMenu.run(SKAction.animate(with: deathMenuAnimation, timePerFrame: 0.05, resize: false, restore: true)) {
            self.addChild(self.pauseCurrentScore)
            self.addChild(self.restartButton)
            self.addChild(self.mainMenuButton)
            self.addChild(self.pauseHighScore)
            self.addChild(self.deathCoinLabel)
            self.addChild(self.settingsButton)
            
            self.areAnimationsDone = true
            
            //interstitial ads
            if UserDefaults.standard.bool(forKey: "purchasedNoAds") == false {
                if self.adCounter < 4 {
                    self.adCounter += 1
                } else {
                    //generate ad
                    print("generating ad")
                    self.adCounter = 1
                    NotificationCenter.default.post(name: .addAd, object: nil)
                }
            }
        }
    }
    
    func closeDeathMenu() {
        
        areAnimationsDone = false
        background1.texture = SKTexture(imageNamed: "main\(self.mainBackground)")
        background2.texture = SKTexture(imageNamed: "main\(self.mainBackground)")
        
        self.reset(toPoint: 0)
        
        deathMenu.position.x = cam.position.x - frame.size.width / 2
        
        deathMenuAnimation.reverse()
        
        deathMenu.run(SKAction.animate(with: deathMenuAnimation, timePerFrame: 0.05, resize: false, restore: true), completion: {
            self.deathMenu.removeFromParent()
            
            self.isDeathMenuOpen = false
            
            self.ball.isHidden = false
            self.scoreCount.isHidden = false
            self.inkBar.isHidden = false
            self.pauseButton.isHidden = false
        })
        
        settingsButton.removeFromParent()
        mainMenuButton.removeFromParent()
        restartButton.removeFromParent()
        pauseCurrentScore.removeFromParent()
        pauseHighScore.removeFromParent()
        deathCoinLabel.removeFromParent()
        
        
    }
    
    func setCurrentInkColor() {
        if UserDefaults.standard.string(forKey: "currentInkColor")! == "black" {
            currentInkColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        } else if UserDefaults.standard.string(forKey: "currentInkColor")! == "gray" {
            currentInkColor = UIColor(red: 206/255, green: 205/255, blue: 205/255, alpha: 1)
        } else if UserDefaults.standard.string(forKey: "currentInkColor")! == "red" {
            currentInkColor = UIColor(red: 220/255, green: 59/255, blue: 62/255, alpha: 1)
        } else if UserDefaults.standard.string(forKey: "currentInkColor")! == "blue" {
            currentInkColor = UIColor(red: 84/255, green: 139/255, blue: 226/255, alpha: 1)
        } else if UserDefaults.standard.string(forKey: "currentInkColor")! == "pink" {
            currentInkColor = UIColor(red: 218/255, green: 101/255, blue: 240/255, alpha: 1)
        } else if UserDefaults.standard.string(forKey: "currentInkColor")! == "limeGreen" {
            currentInkColor = UIColor(red: 104/255, green: 206/255, blue: 93/255, alpha: 1)
        } else {
            print("hi")
        }
    }
    
    
    func loadSettings() {
        let settingsMenu = SettingsMenu(size: size)
        settingsMenu.scaleMode = scaleMode
        let transition = SKTransition.crossFade(withDuration: 0.5)
        view?.presentScene(settingsMenu, transition: transition)
    }
    
}
