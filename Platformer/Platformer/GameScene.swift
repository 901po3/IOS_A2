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
    
    //boolean
    var joystickAction = false
    var jumping = false
    
    //Measure
    var knobRadius : CGFloat = 50.0
    var jumpInterval : CGFloat = 0.0
    
    //Sprite Engine
    var previousTimeInterval : TimeInterval = 0
    var playerIsFacingRight = true
    let playerSpeed = 4.0
    
    //Player State
    var playerStateMachine : GKStateMachine!
    
    //didmove
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
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
        
        // Timer
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {(timer) in
            self.spawnMeteor()
        }
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
}

//MARK : Game Loop
extension GameScene {
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - previousTimeInterval
        previousTimeInterval = currentTime
        
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
            case killing, player, reward, ground //1,2,3,4
            var bitmask: UInt32 { return 1 << self.rawValue } //1,2,4,8
        }
        
        let masks: (first: UInt32, second: UInt32)
        
        func matches (_ first: Masks, _ second: Masks) -> Bool {
            return (first.bitmask == masks.first && second.bitmask == masks.second) ||
                (first.bitmask == masks.second && second.bitmask == masks.first)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let collision = Collision(masks: (first: contact.bodyA.categoryBitMask, second: contact.bodyB.categoryBitMask))
        
        if collision.matches(.player, .killing) {
            let die = SKAction.move(to: CGPoint(x: -300, y: -100), duration: 0.0) //back to initial position
            os_log("trap")
            player?.run(die)
        }
        
        if collision.matches(.player, .ground) {
            
            jumping = false
            
        }
    }
}


//MARK: Meteor
extension GameScene {
    
    func spawnMeteor() {
    
        let node = SKSpriteNode(imageNamed: "meteor")
        node.name = "Meteor"
        let randomXPosition = Int(arc4random_uniform(UInt32(self.size.width)))
        
        node.position = CGPoint(x: randomXPosition, y: 270)
        node.anchorPoint = CGPoint(x: 0.5, y: 1)
        node.zPosition = 5
        
        let physcisBody = SKPhysicsBody(circleOfRadius: 30)
        node.physicsBody = physicsBody
        
        physicsBody?.categoryBitMask = Collision.Masks.killing.bitmask
        physicsBody?.collisionBitMask = Collision.Masks.player.bitmask | Collision.Masks.ground.bitmask
        physcisBody.contactTestBitMask = Collision.Masks.player.bitmask | Collision.Masks.ground.bitmask
        physcisBody.fieldBitMask = Collision.Masks.player.bitmask | Collision.Masks.ground.bitmask
        
        physcisBody.affectedByGravity = true
        physcisBody.allowsRotation = false
        physcisBody.restitution = 0.2
        physcisBody.friction = 10
        
        addChild(node)
    }
}
