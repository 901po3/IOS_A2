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
    
    //didmove
    override func didMove(to view: SKView) {
        player = childNode(withName: "player")
        joystick = childNode(withName: "Joystick")
        joystickKnob = joystick?.childNode(withName: "knob")
    }
}

//MARK: Touches
