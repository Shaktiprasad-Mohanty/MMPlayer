//
//  PotraitNavigationViewController.swift
//  MMPlayer
//
//  Created by Shaktiprasad Mohanty on 30/08/20.
//  Copyright © 2020 MonsterMind. All rights reserved.
//

import UIKit

///This subclass is to make  the homepage orientation fixed for potraitmode
class PotraitNavigationViewController: UINavigationController {
    override var shouldAutorotate : Bool {
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait

        }
    }
}
