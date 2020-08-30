//
//  MMPlayerSlider.swift
//  MMPlayer
//
//  Created by Shaktiprasad Mohanty on 16/08/20.
//  Copyright © 2020 MonsterMind. All rights reserved.
//

import Foundation
import UIKit

open class MMPlayerSlider: UISlider {
    
    open var progressView : UIProgressView!
    
    public override init(frame: CGRect) {
        self.progressView = UIProgressView()
        super.init(frame: frame)
        configureSlider()
    }

    required public init?(coder aDecoder: NSCoder) {
        self.progressView = UIProgressView()
        super.init(coder: aDecoder)
        configureSlider()
    }
    
    override open func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let rect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        let newRect = CGRect(x: rect.origin.x, y: rect.origin.y + 1, width: rect.width, height: rect.height)
        return newRect
    }
    
    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.trackRect(forBounds: bounds)
        let newRect = CGRect(origin: rect.origin, size: CGSize(width: rect.size.width, height: 2.0))
        configureProgressView(newRect)
        return newRect
    }
    
    func configureSlider() {
        maximumValue = 1.0
        minimumValue = 0.0
        value = 0.0
        maximumTrackTintColor = UIColor.clear
        minimumTrackTintColor = UIColor.white
        
        let thumbImage = MMPlayerUtils.imageResource("slider_thumb")
        let normalThumbImage = MMPlayerUtils.imageSize(image: thumbImage!, scaledToSize: CGSize(width: 15, height: 15))
        setThumbImage(normalThumbImage, for: .normal)
        let highlightedThumbImage = MMPlayerUtils.imageSize(image: thumbImage!, scaledToSize: CGSize(width: 20, height: 20))
        setThumbImage(highlightedThumbImage, for: .highlighted)
        
        backgroundColor = UIColor.clear
        progressView.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7988548801)
        progressView.trackTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2964201627)
    }
    
    func configureProgressView(_ frame: CGRect) {
        progressView.frame = frame
        insertSubview(progressView, at: 0)
    }
    
    open func setProgress(_ progress: Float, animated: Bool) {
        progressView.setProgress(progress, animated: animated)
    }
    
}
