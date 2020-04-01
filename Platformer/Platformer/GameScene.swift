//
//  GameScene.swift
//  Platformer
//
//  Created by user162434 on 3/30/20.
//  Copyright © 2020 Hyukin. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    	
    //Nodes
    var player : SKNode?
    var joystick : SKNode?
    var joystickKnob : SKNode?
    
    //boolean
    var joystickAction = false
    
    //Measure
    var knobRadius : CGFloat = 50.0
    
    //Sprite Engine
    var previousTimeInterval : TimeInterval = 0
    var playerIsFacingRight = true
    let playerSpeed = 4.0
    
    //didmove
    override func didMove(to view: SKView) {
        player = childNode(withName: "player")
        joystick = childNode(withName: "Joystick")
        joystickKnob = joystick?.childNode(withName: "knob")
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
        
        // Player Movement
        guard let joystickKnob = joystickKnob else { return }
        let xPostion = Double(joystickKnob.position.x)
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
    }
}
