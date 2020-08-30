//
//  CommonUtility.swift
//  MMPlayer
//
//  Created by Shaktiprasad Mohanty on 26/08/20.
//  Copyright © 2020 MonsterMind. All rights reserved.
//

import UIKit

class CommonUtility: NSObject {
    
    var hudView : UIView?
    var acivityIndicator : UIActivityIndicatorView?
    var captionLabel : UILabel?
    var window: UIWindow?
    override init() {
        window = window ?? appDelegate.window
    }
    
    ///This  method  is to create view controller with storyboard id
    ///@parameters: vcName it takes storyboard viewcontroller id 
    class func getVcObject(vcName:String) -> UIViewController{
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: vcName)
        return vc
    }
    
    // MARK: Show/Remove Activity Indicator
    func showActivityIndicator(withTitle title: String?,andUserInteraction interaction: Bool) {
        if hudView == nil {
            hudView = UIView(frame: CGRect(x: (window!.frame.size.width / 2) - 60, y: (window!.frame.size.height / 2) - 60, width: 120, height: 120))
            hudView!.backgroundColor = UIColor.black
            hudView!.alpha = 0.85
            hudView!.clipsToBounds = true
            hudView!.layer.cornerRadius = 10.0
            
            acivityIndicator = UIActivityIndicatorView(style: .whiteLarge)
            acivityIndicator!.frame = CGRect(x: 40, y: 40, width: acivityIndicator!.bounds.size.width, height: acivityIndicator!.bounds.size.height)
            hudView!.addSubview(acivityIndicator!)
            acivityIndicator!.startAnimating()
            
            captionLabel = UILabel(frame: CGRect(x: 5, y: 80, width: 110, height: 40))
            captionLabel!.backgroundColor = UIColor.clear
            captionLabel!.textColor = UIColor.white
            captionLabel!.adjustsFontSizeToFitWidth = true
            captionLabel!.numberOfLines = 0
            captionLabel!.lineBreakMode = .byWordWrapping
            captionLabel!.textAlignment = .center
            captionLabel!.font = UIFont.systemFont(ofSize: 12.0)
            captionLabel!.text = title
            hudView!.addSubview(captionLabel!)
            window!.isUserInteractionEnabled = false
            window!.addSubview(hudView!)
        }
    }
       
    func removeIndicator() {
        window!.isUserInteractionEnabled = true
        acivityIndicator?.removeFromSuperview()
        captionLabel?.removeFromSuperview()
        hudView?.removeFromSuperview()
        acivityIndicator = nil
        captionLabel = nil
        hudView = nil
    }
}
