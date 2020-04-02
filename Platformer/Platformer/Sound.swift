//
//  Sound.swift
//  Platformer
//
//  Created by user162434 on 4/1/20.
//  Copyright © 2020 Hyukin. All rights reserved.
//

import Foundation
import SpriteKit

enum Sound : String {
    case hit, jump, levelUp, meteorFalling, reward
    
    var action : SKAction {
        return SKAction.playSoundFileNamed(rawValue + "Sound.wav", waitForCompletion: false)
    }
}

extension SKAction {
    static let playGameMusic : SKAction = repeatForever(playSoundFileNamed("music.wav", waitForCompletion: false))
}
