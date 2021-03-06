//
//  Level4.swift
//  Platformer
//
//  Created by user162434 on 4/2/20.
//  Copyright © 2020 Hyukin. All rights reserved.
//

import Foundation
import SpriteKit

class Level4 : GameScene {
    
    override func didMove(to view: SKView) {
        
        super.didMove(to: view)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        super.update(currentTime)
        
        if doorOpen {
            let nextLevel = GameScene(fileNamed: "Level5")
            Data.currentLevel = 5
            nextLevel?.scaleMode = .aspectFill
            view?.presentScene(nextLevel)
        }
    }
}
