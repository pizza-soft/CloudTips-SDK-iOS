//
//  ProgressView.swift
//  Cloudtips-SDK-iOS
//
//  Created by Sergey Iskhakov on 30.09.2020.
//  Copyright © 2020 Cloudtips. All rights reserved.
//

import Foundation

class ProgressView: UIView {
    var bgColor: UIColor = .clear {
        didSet {
            self.backgroundColor = bgColor
        }
    }
    private var progressIcon: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize(){
        self.backgroundColor = .clear
        
        self.progressIcon = UIImageView.init(image: UIImage.bundle("ic_progress"))
        self.progressIcon.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.progressIcon)
        
        self.progressIcon.bindCenterToSuperViewCenter()
    }
    
    func startAnimation(){
        self.stopAnimation()
        
        let animation = CABasicAnimation.init(keyPath: "transform.rotation")
        animation.toValue = NSNumber.init(value: Double.pi * 2.0)
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
        animation.isCumulative = true
        animation.repeatCount = Float.greatestFiniteMagnitude
        self.progressIcon.layer.add(animation, forKey: "rotationAnimation")
    }
    
    func stopAnimation(){
        self.progressIcon.layer.removeAllAnimations()
    }
}
