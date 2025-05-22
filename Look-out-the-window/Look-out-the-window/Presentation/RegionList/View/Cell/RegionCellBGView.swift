//
//  RegionCellBGView.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/22/25.
//

import UIKit

final class RegionCellBGView: UIView {
    
    override func draw(_ rect: CGRect) {
        let cornerRadius: CGFloat = self.frame.height / 8
        let shapeYOffset = self.frame.height * 0.6
        
        let path = UIBezierPath()
                
        // top left point
        path.move(to: CGPoint(x: 0, y: cornerRadius * 2))
        // top left corner
        path.addQuadCurve(to: CGPoint(x: cornerRadius * 2, y: cornerRadius / 2), controlPoint: CGPoint(x: 0, y: 0))
        
        // top right point
        path.addLine(to: CGPoint(x: self.frame.width - cornerRadius, y: self.frame.height - shapeYOffset - cornerRadius / 4))
        // top right corner
        path.addQuadCurve(to: CGPoint(x: self.frame.width, y: self.frame.height - shapeYOffset + cornerRadius), controlPoint: CGPoint(x: self.frame.width, y: self.frame.height - shapeYOffset))
        
        // bottom right point
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height - cornerRadius))
        // bottom right corner
        path.addQuadCurve(to: CGPoint(x: self.frame.width - cornerRadius, y: self.frame.height), controlPoint: CGPoint(x: self.frame.width, y: self.frame.height))
        
        // bottom left point
        path.addLine(to: CGPoint(x: cornerRadius, y: self.frame.height))
        // bottom left corner
        path.addQuadCurve(to: CGPoint(x: 0, y: self.frame.height - cornerRadius), controlPoint: CGPoint(x: 0, y: self.frame.height))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.bounds
        
        self.layer.mask = shapeLayer
        shapeLayer.path = path.cgPath
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
