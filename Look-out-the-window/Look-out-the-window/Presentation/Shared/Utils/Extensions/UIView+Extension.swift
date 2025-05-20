//
//  UIView+Extension.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/20/25.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            self.addSubview($0)
        }
    }
    
    func setViewCornerRadAndShadow(baseView: UIView, cornerRad: CGFloat, shadowOffset: CGSize, shadowRad: CGFloat, shadowOpacity: Float) {
        baseView.layer.masksToBounds = true
        baseView.layer.cornerRadius = cornerRad
        
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRad
        self.layer.shadowOpacity = shadowOpacity
    }
}

