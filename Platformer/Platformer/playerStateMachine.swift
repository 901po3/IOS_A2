//
//  playerStateMachine.swift
//  Platformer
//
//  Created by user162434 on 3/31/20.
//  Copyright © 2020 Hyukin. All rights reserved.
//

import Foundation
import GameplayKit

fileprivate let characterAnimationKey = "Sprite Animation"

class PlayerState : GKState {
    unowned var playerNode : SKNode
    
    init(playerNode : SKNode){
        self.playerNode = playerNode
        
        super.init()
    }
}

class JumpingState : PlayerState {
    var hasFinishedJumping : Bool = false
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
       // if hasFinishedJumping && stateClass is LandingState.Type { return true }
        return true
    }
    
    
    //let textures : Array<SKTexture> = (2..<3).map({return "A_Jump_\($0)"}).map(SKTexture.init)
    //lazy var action = {SKAction.animate(with: textures, timePerFrame: 0.1)} ()
    
    override func didEnter(from previousState: GKState?) {
        
        //playerNode.removeAction(forKey: characterAnimationKey)
        //playerNode.run(action, withKey: characterAnimationKey)
        hasFinishedJumping = false
        playerNode.run(.applyForce(CGVector(dx: 0, dy: 250), duration: 0.1))
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) {(timer) in
            self.hasFinishedJumping = true
        }
    }
}

class LandingState : PlayerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is LandingState.Type, is JumpingState.Type: return false
        default: return true
        }
    }
    
    //let textures : Array<SKTexture> = (0..<2).map({return "A_Land_\($0)"}).map(SKTexture.init)
    //lazy var action = {SKAction.animate(with: textures, timePerFrame: 0.1)} ()
    
    override func didEnter(from previousState: GKState?) {
        //playerNode.removeAction(forKey: characterAnimationKey)
        //playerNode.run(action, withKey: characterAnimationKey)
        
        stateMachine?.enter(IdleState.self)
    }
}

class IdleState : PlayerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is LandingState.Type, is IdleState.Type: return false
        default: return true
        }
    }
    
    let textures : Array<SKTexture> = (0..<6).map({return "A_Idle_\($0)"}).map(SKTexture.init)
    lazy var action = {SKAction.repeatForever(.animate(with: textures, timePerFrame: 0.1))} ()
    
    override func didEnter(from previousState: GKState?) {
        playerNode.removeAction(forKey: characterAnimationKey)
        playerNode.run(action, withKey: characterAnimationKey)
    }
}

class WalkingState : PlayerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is LandingState.Type, is WalkingState.Type : return false
        default: return true
        }
    }
    
    let textures : Array<SKTexture> = (0..<10).map({return "A_Run_\($0)"}).map(SKTexture.init)
    lazy var action = {SKAction.repeatForever(.animate(with: textures, timePerFrame: 0.1))} ()
    
    override func didEnter(from previousState: GKState?) {
        playerNode.removeAction(forKey: characterAnimationKey)
        playerNode.run(action, withKey: characterAnimationKey)
    }
}

class StunnedState : PlayerState {
    
}
