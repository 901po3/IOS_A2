//
//  GameScene.swift
//  Platformer
//
//  Created by user162434 on 3/30/20.
//  Copyright © 2020 Hyukin. All rights reserved.
//

import SpriteKit
import GameplayKit
import os.log

class GameScene: SKScene {
    	
    //Nodes
    var player : SKNode?
    var joystick : SKNode?
    var joystickKnob : SKNode?
    var cameraNode : SKNode?
    var mountain1 : SKNode?
    var mountain2 : SKNode?
    var mountain3 : SKNode?
    var mountain4 : SKNode?
    var star1 : SKNode?
    var star2 : SKNode?
    var moon : SKNode?
    
    // Boolean
    var joystickAction = false
    var jumping = false
    var rewardIsNotTouched = true
    var isHit = false
    var hasKey = false
    var doorOpen = false
    
    // Measure
    var knobRadius : CGFloat = 50.0
    var jumpInterval : CGFloat = 0.0
    
    // Score
    let scoreLabel = SKLabelNode()
    var score = 0
    
    // Key
    var keyContainer = SKLabelNode()
    
    // Heart
    var heartArray = [SKSpriteNode]()
    let heartContainer = SKLabelNode()
    
    //Sprite Engine
    var previousTimeInterval : TimeInterval = 0
    var playerIsFacingRight = true
    let playerSpeed = 4.0
    
    // Player State
    var playerStateMachine : GKStateMachine!
    
    // didmove
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        let soundAction = SKAction.repeatForever(SKAction.playSoundFileNamed("music.wav", waitForCompletion: false))
        run(soundAction)
        
        player = childNode(withName: "player")
        joystick = childNode(withName: "Joystick")
        joystickKnob = joystick?.childNode(withName: "knob")
        cameraNode = childNode(withName: "CameraNode")
        mountain1 = childNode(withName: "mountain1")
        mountain2 = childNode(withName: "mountain2")
        mountain3 = childNode(withName: "mountain3")
        mountain4 = childNode(withName: "mountain4")
        star1 = childNode(withName: "star1")
        star2 = childNode(withName: "star2")
        moon = childNode(withName: "moon")

        playerStateMachine = GKStateMachine(states: [
            JumpingState(playerNode: player!),
            WalkingState(playerNode: player!),
            IdleState(playerNode: player!),
            LandingState(playerNode: player!),
            StunnedState(playerNode: player!)
        ])
        
        playerStateMachine.enter(IdleState.self)
        
        // Hearts
        heartContainer.position = CGPoint(x: -300, y: 140)
        heartContainer.zPosition = 5
        cameraNode?.addChild(heartContainer)
        self.fillHearts(count: 5)
        
        keyContainer.position = CGPoint(x: (cameraNode?.position.x)! + 250, y: 150)
        keyContainer.zPosition = 5
        keyContainer.alpha = 0.2
        cameraNode?.addChild(keyContainer)
        let key = SKSpriteNode(imageNamed: "key")
        key.size = CGSize(width: 27, height: 27)
        keyContainer.addChild(key)
        
        // Timer
        //Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {(timer) in
        //    os_log("timer fired")
        //    self.spawnMeteor()
        //}
        
        scoreLabel.position = CGPoint(x: (cameraNode?.position.x)! +  310, y: 140)
        scoreLabel.fontColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        scoreLabel.fontSize = 24
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.text = String(score)
        cameraNode?.addChild(scoreLabel)
    }
}

//MARK: Touches
extension GameScene{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if let joystickKnob = joystickKnob {
                let location = touch.location(in: joystick!)
                joystickAction = joystickKnob.frame.contains(location)
            }
            
            
            //let location = touch.location(in: self)
            //if !(joystick?.contains(location))! {
            //    playerStateMachine.enter(JumpingState.self)
            //}
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let joystick = joystick else { return }
        guard let joystickKnob = joystickKnob else { return }
        
        if !joystickAction { return }
        
        for touch in touches {
            let position = touch.location(in: joystick)
            
            let length = sqrt(pow(position.y, 2) + pow(position.x, 2))
            let angle = atan2(position.y, position.x)
            
            if knobRadius > length {
                joystickKnob.position = position
            } else {
                joystickKnob.position = CGPoint(x: cos(angle) * knobRadius, y: sin(angle) * knobRadius)
            }
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let xJoystickCoordinate = touch.location(in: joystick!).x
            let xLimit: CGFloat = 200.0
            if xJoystickCoordinate > -xLimit && xJoystickCoordinate < xLimit {
                resetKnobPosition()
            }
        }
    }
}

//MARK: Action
extension GameScene {
    
    func resetKnobPosition() {
        let initialPoint = CGPoint(x: 0, y: 0)
        //let moveBack = SKAction.move(to: initialPoint, duration: 0.1)
        //moveBack.timingMode = .linear
        //joystickKnob?.run(moveBack)
        joystickKnob?.position = initialPoint
        joystickAction = false
    }
    
    func rewardTouch() {
        score += 1
        scoreLabel.text = String(score)
    }
    
    func fillHearts(count: Int) {
        for index in 1...count {
            let heart = SKSpriteNode(imageNamed: "heart")
            let xPosition = heart.size.width * CGFloat(index - 1)
            heart.position = CGPoint(x: xPosition, y: 0)
            heartArray.append(heart)
            heartContainer.addChild(heart)
        }
    }
    
    func loseHeart() {
        if isHit {
            let lastElementIndex = heartArray.count - 1
            if heartArray.indices.contains(lastElementIndex - 1) {
                let lastHeart = heartArray[lastElementIndex]
                lastHeart.removeFromParent()
                heartArray.remove(at: lastElementIndex)
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                    self.isHit = false
                }
            }
            else {
                LostAllHearts()
            }
            //invincible()
        }
    }
    
    func invincible() {
        player?.physicsBody?.categoryBitMask = 0
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
            self.player?.physicsBody?.categoryBitMask = 2
        }
    }
    
    func LostAllHearts() {
        fillHearts(count: 5)
        let gameOverScene = GameScene(fileNamed: "GameOver")
        self.view?.presentScene(gameOverScene)
    }
    
    
    
    func Dying() {
        let dieAction = SKAction.move(to: CGPoint(x: -300, y: 0), duration: 0.1)
        player?.run(dieAction)
        self.removeAllActions()
    }
}

//MARK : Game Loop
extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - previousTimeInterval
        previousTimeInterval = currentTime
        
        rewardIsNotTouched = true
        
        //Camera
        cameraNode?.position.x = player!.position.x
        joystick?.position.y = (cameraNode?.position.y)! - 100
        joystick?.position.x = (cameraNode?.position.x)! - 300
        
        // Player Movement
        guard let joystickKnob = joystickKnob else { return }
        let xPostion = Double(joystickKnob.position.x)
        let positivePosition = xPostion < 0 ? -xPostion : xPostion
        
        if(floor(positivePosition) != 0) {
            playerStateMachine.enter(WalkingState.self)
        } else {
            playerStateMachine.enter(IdleState.self)
        }
        let displacement = CGVector(dx: deltaTime * xPostion * playerSpeed, dy: 0)
        let move = SKAction.move(by: displacement, duration: 0)
        let faceAction : SKAction!
        let movingRight = xPostion > 0
        let movingLeft = xPostion < 0
        if movingLeft && playerIsFacingRight {
            playerIsFacingRight = false
            let faceMovement = SKAction.scaleX(to: abs(player!.xScale) * -1, duration: 0.0)
            faceAction = SKAction.sequence([move, faceMovement])
        } else if movingRight && !playerIsFacingRight {
            playerIsFacingRight = true
            let faceMovement = SKAction.scaleX(to: abs(player!.xScale) * 1, duration: 0.0)
            faceAction = SKAction.sequence([move, faceMovement])
        } else {
            faceAction = move
        }
        player?.run(faceAction)
        
        // Background Parallax
             
            let parallx4 = SKAction.moveTo(x: (cameraNode?.position.x)!, duration: 0.0)
            star1?.run(parallx4)
            star2?.run(parallx4)
            moon?.run(parallx4)
        
        // Player Jump
        if joystickKnob.position.y > 20 && !jumping {
            jumping = true
            playerStateMachine.enter(JumpingState.self)
            
 

        }
    }
}

//MARK: Collision
extension GameScene: SKPhysicsContactDelegate {
    
    struct Collision {
        
        enum Masks: Int {
            case killing, player, reward, ground, door //1,2,3,4,5
            var bitmask: UInt32 { return 1 << self.rawValue } //1,2,4,8,16
        }
        
        let masks: (first: UInt32, second: UInt32)
        
        func matches (_ first: Masks, _ second: Masks) -> Bool {
            return (first.bitmask == masks.first && second.bitmask == masks.second) ||
                (first.bitmask == masks.second && second.bitmask == masks.first)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let collision = Collision(masks: (first: contact.bodyA.categoryBitMask, second: contact.bodyB.categoryBitMask))
        
        if collision.matches(.player, .killing)  {
            if isHit == false {
                run(Sound.hit.action)
                isHit = true
                loseHeart()
                Dying()
            }
        }
        
        if collision.matches(.player, .ground) {
            jumping = false
        }
        
        if collision.matches(.player, .reward) {
            
            if contact.bodyA.node?.name == "jewel" {
                contact.bodyA.node?.physicsBody?.categoryBitMask = 0;
                contact.bodyA.node?.removeFromParent()
                if rewardIsNotTouched {
                    rewardTouch()
                    rewardIsNotTouched = false
                    run(Sound.reward.action)
                }
            } else if contact.bodyB.node?.name == "jewel" {
                contact.bodyB.node?.physicsBody?.categoryBitMask = 0;
                contact.bodyB.node?.removeFromParent()
                if rewardIsNotTouched {
                    rewardTouch()
                    rewardIsNotTouched = false
                    run(Sound.reward.action)
                }
            }

            
            if contact.bodyA.node?.name == "key" {
                contact.bodyA.node?.physicsBody?.categoryBitMask = 0;
                contact.bodyA.node?.removeFromParent()
                keyContainer.alpha = 1.0
                hasKey = true
                run(Sound.reward.action)
            } else if contact.bodyB.node?.name == "key" {
                contact.bodyB.node?.physicsBody?.categoryBitMask = 0;
                contact.bodyB.node?.removeFromParent()
                keyContainer.alpha = 1.0
                hasKey = true
                run(Sound.reward.action)
            }
            
        }
        
        if collision.matches(.player, .door) {
            if contact.bodyA.node?.name == "door" && hasKey {
                contact.bodyA.node?.physicsBody?.categoryBitMask = 0;
                doorOpen = true
                if doorOpen {
                    os_log("go to next level")
                }
            } else if contact.bodyB.node?.name == "door" && hasKey {
                contact.bodyA.node?.physicsBody?.categoryBitMask = 0;
                doorOpen = true
                if doorOpen {
                    os_log("go to next level")
                }
            }
        }
        
        if collision.matches(.ground, .killing) {
            if contact.bodyA.node?.name == "Meteor", let meteor = contact.bodyA.node {
                createMolten(at: meteor.position)
                meteor.removeFromParent()
            }
            if contact.bodyB.node?.name == "Meteor", let meteor = contact.bodyB.node {
                createMolten(at: meteor.position)
                meteor.removeFromParent()
            }
            run(Sound.meteorFalling.action)
        }
    }
}


//MARK: Meteor
extension GameScene {
    
    func spawnMeteor() {
    
        let node = SKSpriteNode(imageNamed: "meteor")
        node.name = "Meteor"
        let randomXPosition = Int(arc4random_uniform(UInt32(self.size.width)))
        
        node.position = CGPoint(x: randomXPosition, y: 0)
        node.anchorPoint = CGPoint(x: 0.5, y: 1)
        node.zPosition = 5
        
        let physcisBody = SKPhysicsBody(circleOfRadius: 30)
        
        physcisBody.affectedByGravity = true
        physcisBody.allowsRotation = false
        physcisBody.restitution = 0.2
        physcisBody.friction = 10
                
        physicsBody!.categoryBitMask = Collision.Masks.killing.bitmask
        physicsBody!.collisionBitMask = Collision.Masks.player.bitmask | Collision.Masks.ground.bitmask
        physcisBody.contactTestBitMask = Collision.Masks.player.bitmask | Collision.Masks.ground.bitmask
        physcisBody.fieldBitMask = Collision.Masks.player.bitmask | Collision.Masks.ground.bitmask
        
        node.physicsBody = physcisBody
        
        addChild(node)
    }
    
    func createMolten(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "molten")
        node.position.x = position.x
        node.position.y = position.y - 110
        node.zPosition = 4
        
        addChild(node)
        
        let action = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.1),
            SKAction.wait(forDuration: 3.0),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ])
        
        node.run(action)
    }
}
