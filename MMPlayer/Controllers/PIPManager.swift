//
//  PIPManager.swift
//  MMPlayer
//
//  Created by Shaktiprasad Mohanty on 30/08/20.
//  Copyright © 2020 MonsterMind. All rights reserved.
//

import UIKit

/// This singleton class is to hold required objects for PIP mode
class PIPManager {
    var video : Video?
    var player : MMPlayer?
    
    init() {
    }
    class var shared: PIPManager {
        struct Singleton {
            static let instance = PIPManager()
        }
        return Singleton.instance
    }
}
