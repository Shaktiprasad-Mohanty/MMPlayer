//
//  VideoDBM.swift
//  MMPlayer
//
//  Created by Shaktiprasad Mohanty on 26/08/20.
//  Copyright © 2020 MonsterMind. All rights reserved.
//

import UIKit
import CoreData

class VideoDBM {
    fileprivate var mainContextInstance: NSManagedObjectContext!
    init() {
        self.mainContextInstance = appDelegate.persistentContainer.viewContext
    }
    class var shared: VideoDBM {
        struct Singleton {
            static let instance = VideoDBM()
        }
        
        return Singleton.instance
    }
    
    func deleteAll() {
        let privateManagedObjectContext: NSManagedObjectContext =
            NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        privateManagedObjectContext.parent = self.mainContextInstance
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try privateManagedObjectContext.execute(deleteRequest)
            try privateManagedObjectContext.save()
        } catch {
            print ("There was an error")
        }
    }
    
    func checkAndSaveVideos() {
        if fetchCount() > 0 {
            return
        }
        
        let videos = [["created_at":"2019-02-22 16:34:26",
                       "details":"Big Buck Bunny tells the story of a giant rabbit with a heart bigger than himself. When one sunny day three rodents rudely harass him, something snaps... and the rabbit ain't no bunny anymore! In the typical cartoon tradition he prepares the nasty rodents a comical revenge.\n\nLicensed under the Creative Commons Attribution license\nhttp://www.bigbuckbunny.org",
                       "image_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg",
                       "is_fav":true,
                       "last_open":"2019-03-22 16:34:26",
                       "likes":123234,
                       "name":"Big Buck Bunny",
                       "source" : "By Blender Foundation",
                       "played_duration":0.0,
                       "video_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"],
                      ["created_at":"2019-01-02 14:34:26",
                       "details":"The first Blender Open Movie from 2006",
                       "image_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg",
                       "is_fav":false,
                       "last_open":"2019-02-22 16:34:26",
                       "likes":443535,
                       "source" : "By Blender Foundation",
                       "name":"Elephant Dream",
                       "played_duration":132.0,
                       "video_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"],
                      ["created_at":"2018-07-21 16:34:26",
                       "details":"HBO GO now works with Chromecast -- the easiest way to enjoy online video on your TV. For when you want to settle into your Iron Throne to watch the latest episodes. For $35.\nLearn how to use Chromecast with HBO GO and more at google.com/chromecast.",
                       "image_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg",
                       "is_fav":false,
                       "last_open":"2020-01-12 16:34:26",
                       "likes":442535,
                       "source" : "By Google",
                       "name":"For Bigger Blazes",
                       "played_duration":0.0,
                       "video_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"],
                      ["created_at":"2019-03-13 16:34:26",
                       "details":"Introducing Chromecast. The easiest way to enjoy online video and music on your TV—for when Batman's escapes aren't quite big enough. For $35. Learn how to use Chromecast with Google Play Movies and more at google.com/chromecast.",
                       "image_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg",
                       "is_fav":false,
                       "last_open":"2019-02-22 16:34:26",
                       "likes":343535,
                       "source" : "By Google",
                       "name":"For Bigger Escape",
                       "played_duration":0.0,
                       "video_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"],
                      ["created_at":"2020-08-12 16:34:26",
                       "details":"Introducing Chromecast. The easiest way to enjoy online video and music on your TV. For $35.  Find out more at google.com/chromecast.",
                       "image_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerFun.jpg",
                       "is_fav":false,
                       "last_open":"2019-02-22 16:34:26",
                       "likes":446747,
                       "source" : "By Google",
                       "name":"For Bigger Fun",
                       "played_duration":0.0,
                       "video_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4"],
                      ["created_at":"2019-09-09 16:34:26",
                       "details":"Introducing Chromecast. The easiest way to enjoy online video and music on your TV—for the times that call for bigger joyrides. For $35. Learn how to use Chromecast with YouTube and more at google.com/chromecast.",
                       "image_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg",
                       "is_fav":false,
                       "last_open":"2019-02-22 16:34:26",
                       "likes":526627,
                       "source" : "By Google",
                       "name":"For Bigger Joyrides",
                       "played_duration":0.0,
                       "video_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4"],
                      ["created_at":"2019-02-25 16:34:26",
                       "details":"Introducing Chromecast. The easiest way to enjoy online video and music on your TV—for when you want to make Buster's big meltdowns even bigger. For $35. Learn how to use Chromecast with Netflix and more at google.com/chromecast.",
                       "image_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerMeltdowns.jpg",
                       "is_fav":false,
                       "last_open":"2019-02-22 16:34:26",
                       "likes":232444,
                       "source" : "By Google",
                       "name":"For Bigger Meltdowns",
                       "played_duration":0.0,
                       "video_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4"],
                      ["created_at":"2019-12-27 16:34:26",
                       "details":"Sintel is an independently produced short film, initiated by the Blender Foundation as a means to further improve and validate the free/open source 3D creation suite Blender. With initial funding provided by 1000s of donations via the internet community, it has again proven to be a viable development model for both open 3D technology as for independent animation film.\nThis 15 minute film has been realized in the studio of the Amsterdam Blender Institute, by an international team of artists and developers. In addition to that, several crucial technical and creative targets have been realized online, by developers and artists and teams all over the world.\nwww.sintel.org",
                       "image_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg",
                       "is_fav":false,
                       "last_open":"2019-02-22 16:34:26",
                       "likes":124525,
                       "source" : "By Blender Foundation",
                       "name":"Sintel",
                       "played_duration":0.0,
                       "video_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"],
                      ["created_at":"2020-05-29 16:34:26",
                       "details":"Smoking Tire takes the all-new Subaru Outback to the highest point we can find in hopes our customer-appreciation Balloon Launch will get some free T-shirts into the hands of our viewers.",
                       "image_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/SubaruOutbackOnStreetAndDirt.jpg",
                       "is_fav":false,
                       "last_open":"2019-02-22 16:34:26",
                       "likes":473535,
                       "source" : "By Garage419",
                       "name":"Subaru Outback On Street And Dirt",
                       "played_duration":0.0,
                       "video_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4"],
                      ["created_at":"2019-05-02 16:34:26",
                       "details":"Tears of Steel was realized with crowd-funding by users of the open source 3D creation tool Blender. Target was to improve and test a complete open and free pipeline for visual effects in film - and to make a compelling sci-fi film in Amsterdam, the Netherlands.  The film itself, and all raw material used for making it, have been released under the Creatieve Commons 3.0 Attribution license. Visit the tearsofsteel.org website to find out more about this, or to purchase the 4-DVD box with a lot of extras.  (CC) Blender Foundation - http://www.tearsofsteel.org",
                       "image_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg",
                       "is_fav":false,
                       "last_open":"2019-04-23 16:34:26",
                       "likes":765135,
                       "source" : "By Blender Foundation",
                       "name":"Tears of Steel",
                       "played_duration":0.0,
                       "video_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"],
                      ["created_at":"2019-02-22 16:34:26",
                       "details":"The Smoking Tire heads out to Adams Motorsports Park in Riverside, CA to test the most requested car of 2010, the Volkswagen GTI. Will it beat the Mazdaspeed3's standard-setting lap time? Watch and see...",
                       "image_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/VolkswagenGTIReview.jpg",
                       "is_fav":false,
                       "last_open":"2019-02-22 16:34:26",
                       "likes":232454,
                       "source" : "By Garage419",
                       "name":"Volkswagen GTI Review",
                       "played_duration":0.0,
                       "video_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4"],
                      ["created_at":"2020-01-20 16:34:26",
                       "details":"The Smoking Tire is going on the 2010 Bullrun Live Rally in a 2011 Shelby GT500, and posting a video from the road every single day! The only place to watch them is by subscribing to The Smoking Tire or watching at BlackMagicShine.com",
                       "image_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/WeAreGoingOnBullrun.jpg",
                       "is_fav":false,
                       "last_open":"2019-02-22 16:34:26",
                       "likes":544344,
                       "source" : "By Garage419",
                       "name":"We Are Going On Bullrun",
                       "played_duration":0.0,
                       "video_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4"],
                      ["created_at":"2020-01-18 11:34:26",
                       "details":"The Smoking Tire meets up with Chris and Jorge from CarsForAGrand.com to see just how far $1,000 can go when looking for a car.The Smoking Tire meets up with Chris and Jorge from CarsForAGrand.com to see just how far $1,000 can go when looking for a car.",
                       "image_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/WhatCarCanYouGetForAGrand.jpg",
                       "is_fav":false,
                       "last_open":"2019-02-22 16:34:26",
                       "likes":322323,
                       "source" : "By Garage419",
                       "name":"What care can you get for a grand?",
                       "played_duration":0.0,
                       "video_url":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4"]]
        
        //Minion Context worker with Private Concurrency type.
        let privateManagedObjectContext: NSManagedObjectContext =
            NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        privateManagedObjectContext.parent = self.mainContextInstance
        
        
        for video in videos  {
            let videoObj = NSEntityDescription.insertNewObject(forEntityName: String(describing: Video.self), into: privateManagedObjectContext) as! Video
            videoObj.id = UUID()
            videoObj.created_at = (video["created_at"] as! String).getDate()
            videoObj.details = video["details"] as? String
            videoObj.image_url = video["image_url"] as? String
            videoObj.is_fav = video["is_fav"] as? Bool ?? false
            videoObj.last_open = (video["last_open"] as! String).getDate()
            videoObj.likes = video["likes"] as? Double ?? 0.0
            videoObj.source = video["source"] as? String
            videoObj.name = video["name"] as? String
            videoObj.played_duration = video["played_duration"] as? Double ?? 0.0
            videoObj.video_url = video["video_url"] as? String
            saveContext(privateManagedObjectContext)
        }
        saveMainContext()
        
    }
    
    func fetchAll() ->  [Video]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Video.self))
        var fetchedResults = [Video]()
        do {
            fetchedResults = try self.mainContextInstance.fetch(fetchRequest) as! [Video]
            print(fetchedResults)
            
        } catch let updateError as NSError {
            print("updateAllEventAttendees error: \(updateError.localizedDescription)")
            
        }
        return fetchedResults
    }
    
    func fetchForCoresal() ->  [Video]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Video.self))
        let sortbycreatedAt = NSSortDescriptor(key:"created_at",
                                               ascending: false)
        let sortbylike = NSSortDescriptor(key:"likes",
                                          ascending: false)
        let sortDescriptors = [sortbylike,sortbycreatedAt]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchLimit = 5
        var fetchedResults = [Video]()
        do {
            fetchedResults = try self.mainContextInstance.fetch(fetchRequest) as! [Video]
            print(fetchedResults)
            
        } catch let updateError as NSError {
            print("updateAllEventAttendees error: \(updateError.localizedDescription)")
            
        }
        return fetchedResults
    }
    func fetchForNewRelease() ->  [Video]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Video.self))
        let sortbycreatedAt = NSSortDescriptor(key:"created_at",
                                               ascending: false)
        let sortDescriptors = [sortbycreatedAt]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchLimit = 10
        var fetchedResults = [Video]()
        do {
            fetchedResults = try self.mainContextInstance.fetch(fetchRequest) as! [Video]
            print(fetchedResults)
            
        } catch let updateError as NSError {
            print("updateAllEventAttendees error: \(updateError.localizedDescription)")
            
        }
        return fetchedResults
    }
    func fetchForTreding() ->  [Video]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Video.self))
        let sortbylike = NSSortDescriptor(key:"likes",
                                          ascending: false)
        let sortDescriptors = [sortbylike]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchLimit = 10
        var fetchedResults = [Video]()
        do {
            fetchedResults = try self.mainContextInstance.fetch(fetchRequest) as! [Video]
            print(fetchedResults)
            
        } catch let updateError as NSError {
            print("updateAllEventAttendees error: \(updateError.localizedDescription)")
            
        }
        return fetchedResults
    }
   
    func updateFavValue(isFav : Bool, for id:UUID){
        // Create a fetch request for the entity Person
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Video.self))
        let findByid =
            NSPredicate(format: "id = %@", id as CVarArg)
        fetchRequest.predicate = findByid
        // Execute the fetch request
        var video : Video
        do {
            video = try self.mainContextInstance.fetch(fetchRequest).first as! Video
            video.is_fav = isFav
        } catch let updateError as NSError {
            print("updateAllEventAttendees error: \(updateError.localizedDescription)")
        }
    }
    
    
    func updateLastPlayedDuration(duration : Double, for id:UUID){
        // Create a fetch request for the entity Person
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Video.self))
        let findByid =
            NSPredicate(format: "id = %@", id as CVarArg)
        fetchRequest.predicate = findByid
        // Execute the fetch request
        var video : Video
        do {
            video = try self.mainContextInstance.fetch(fetchRequest).first as! Video
            video.played_duration = duration
        } catch let updateError as NSError {
            print("updateAllEventAttendees error: \(updateError.localizedDescription)")
        }
    }
    
    
    
    func fetchCount() -> Int{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:String(describing: Video.self))
        var count = 0
        do {
            count = try self.mainContextInstance.count(for: fetchRequest)
            return count
        }catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            return count
        }
    }
    
    
    
    /**
     Save the  changes on the current context.
     
     - Returns: Void
     */
    func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch let saveError as NSError {
            print("save minion worker error: \(saveError.localizedDescription)")
        }
    }
    
    /**
     Save and merge the  changes on the current context with Main context.
     
     - Returns: Void
     */
    func saveMainContext() {
        do {
            try self.mainContextInstance.save()
        } catch let saveError as NSError {
            print("synWithMainContext error: \(saveError.localizedDescription)")
        }
    }
    
    
}
