//
//  Video+CoreDataProperties.swift
//  MMPlayer
//
//  Created by Shaktiprasad Mohanty on 29/08/20.
//  Copyright © 2020 MonsterMind. All rights reserved.
//
//

import Foundation
import CoreData


extension Video {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Video> {
        return NSFetchRequest<Video>(entityName: "Video")
    }

    @NSManaged public var created_at: Date?
    @NSManaged public var details: String?
    @NSManaged public var id: UUID?
    @NSManaged public var image_url: String?
    @NSManaged public var is_fav: Bool
    @NSManaged public var last_open: Date?
    @NSManaged public var likes: Double
    @NSManaged public var name: String?
    @NSManaged public var played_duration: Double
    @NSManaged public var source: String?
    @NSManaged public var video_url: String?

}
