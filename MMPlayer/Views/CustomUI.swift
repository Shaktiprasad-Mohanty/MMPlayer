//
//  CustomUI.swift
//  MMPlayer
//
//  Created by Shaktiprasad Mohanty on 27/08/20.
//  Copyright © 2020 MonsterMind. All rights reserved.
//

import UIKit
@IBDesignable
// MARK: - View Customize -
class AttributedView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isRounded {
            layer.cornerRadius = bounds.size.height / 2
        }
        
    }
    
    @IBInspectable var isRounded: Bool = false {
        didSet {
            if isRounded {
                layer.cornerRadius = bounds.size.height / 2
            }
        }
    }
    
     //   roundCorners(corners: [.topRight, .bottomRight], radius: 5.0)

    
    // MARK: - Border
    
    @IBInspectable public var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }
    
    // MARK: - Shadow
    
    @IBInspectable public var shadowOpacity: CGFloat = 0 {
        didSet {
            layer.shadowOpacity = Float(shadowOpacity)
        }
    }
    
    @IBInspectable public var shadowColor: UIColor = UIColor.clear {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable public var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable public var shadowOffsetY: CGFloat = 0 {
        didSet {
            layer.shadowOffset.height = shadowOffsetY
        }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

///Sub class to make circular UIlabels with managed insects to avoid text clipping
class RoundedCornerLabel: UILabel {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: UIEdgeInsets(top: 5.0, left: cornerRadius, bottom: 5.0, right: cornerRadius)))
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        
        let edgeInsets = UIEdgeInsets(top: 5.0, left: cornerRadius, bottom: 5.0, right: cornerRadius)
        size.width += edgeInsets.left + edgeInsets.right
        size.height += edgeInsets.top + edgeInsets.bottom
        
        return size
    }
}
