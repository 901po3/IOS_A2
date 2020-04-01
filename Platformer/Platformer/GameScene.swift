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
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let joystick = joystick else { return }
        guard let joystickKnob = joystickKnob else { return }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
