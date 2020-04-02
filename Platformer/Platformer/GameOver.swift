//
//  GameOver.swift
//  Platformer
//
//  Created by user162434 on 4/1/20.
//  Copyright © 2020 Hyukin. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene : SKScene {
    override func sceneDidLoad() {
        Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { (timer) in
            Data.collectedCoin = 0
            Data.currentLevel = 1
            Data.health = 5
            let level1 = GameScene(fileNamed: "Level1")
            self.view?.presentScene(level1)
            self.removeAllActions()
        }
    }
}
