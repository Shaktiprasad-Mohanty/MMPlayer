//
//  ImageDownloader.swift
//  MMPlayer
//
//  Created by Shaktiprasad Mohanty on 27/08/20.
//  Copyright © 2020 MonsterMind. All rights reserved.
//

import UIKit
class ImageDownloader{
    private let cache : NSCache<NSString, UIImage>
    
    init() {
        self.cache = NSCache<NSString, UIImage>()
    }
    class var shared: ImageDownloader {
        struct Singleton {
            static let instance = ImageDownloader()
        }
        return Singleton.instance
    }
    
    func setImage(urlString:String,imageView : UIImageView){
        if(cache.object(forKey: urlString as NSString) != nil){
            imageView.image = cache.object(forKey: urlString as NSString)
        }else{
            let concurrentQueue = DispatchQueue(label: "com.mmplayer.currentQueue", attributes: .concurrent)
            concurrentQueue.async {
                if let url = URL(string: urlString){
                    do{
                        let imgData = try Data(contentsOf: url, options: .mappedIfSafe)
                        let img = UIImage(data: imgData)
                        self.cache.setObject(img!, forKey: urlString as NSString)
                        DispatchQueue.main.async {
                            imageView.image = img
                        }
                    } catch let e {
                        print(e)
                    }
                }
            }
        }
        
    }
    
}

