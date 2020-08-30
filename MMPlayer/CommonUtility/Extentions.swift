//
//  Extentions.swift
//  MMPlayer
//
//  Created by Shaktiprasad Mohanty on 16/08/20.
//  Copyright © 2020 MonsterMind. All rights reserved.
//

import Foundation
extension Timer {
    class func mmPlayer_scheduledTimerWithTimeInterval(_ timeInterval: TimeInterval, block: @escaping ()->(), repeats: Bool) -> Timer {
        return self.scheduledTimer(timeInterval: timeInterval, target:
            self, selector: #selector(self.mmPlayer_blcokInvoke(_:)), userInfo: block, repeats: repeats)
    }
    
    @objc class func mmPlayer_blcokInvoke(_ timer: Timer) {
        let block: ()->() = timer.userInfo as! ()->()
        block()
    }

}
