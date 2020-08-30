//
//  MMPlayerError.swift
//  MMPlayer
//
//  Created by Shaktiprasad Mohanty on 16/08/20.
//  Copyright © 2020 MonsterMind. All rights reserved.
//

import Foundation
import AVFoundation

public struct MMPlayerError: CustomStringConvertible {
    var error : Error?
    var playerItemErrorLogEvent : [AVPlayerItemErrorLogEvent]?
    var extendedLogData : Data?
    var extendedLogDataStringEncoding : UInt?
    
   public var description: String {
        return "MMPlayer Log error: \(String(describing: error))\n playerItemErrorLogEvent: \(String(describing: playerItemErrorLogEvent))\n extendedLogData: \(String(describing: extendedLogData))\n extendedLogDataStringEncoding \(String(describing: extendedLogDataStringEncoding))"
    }
}
