//
//  LaunchViewController.swift
//  MMPlayer
//
//  Created by Shaktiprasad Mohanty on 26/08/20.
//  Copyright © 2020 MonsterMind. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        preloadDatabase()
    }
    func preloadDatabase() {
        
        VideoDBM.shared.checkAndSaveVideos()
        self.navigationController?.pushViewController(CommonUtility.getVcObject(vcName: "HomeViewController"), animated: true)
    }
    
}
