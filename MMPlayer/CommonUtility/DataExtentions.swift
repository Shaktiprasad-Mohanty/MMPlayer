//
//  DataExtentions.swift
//  MMPlayer
//
//  Created by Shaktiprasad Mohanty on 26/08/20.
//  Copyright © 2020 MonsterMind. All rights reserved.
//

import Foundation

extension String{
    func getDate(_ dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: self) ?? Date()
    }
}
