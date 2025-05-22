//
//  RegionCellBGView.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/22/25.
//

import UIKit

/// `RegionCell`에 사용되는 사다리꼴 모양 배경 `UIView`
final class RegionCellBGView: UIView {
    
    // MARK: - Lifecycle
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let width = rect.width
        let height = rect.height
        let cornerRadius: CGFloat = height / 8
        let shapeYOffset = height * 0.6
        
        let path = UIBezierPath()
                
        // top left point
        path.move(to: CGPoint(x: 0, y: cornerRadius * 2))
        // top left corner
        path.addQuadCurve(to: CGPoint(x: cornerRadius * 2, y: cornerRadius / 2), controlPoint: CGPoint(x: 0, y: 0))
        
        // top right point
        path.addLine(to: CGPoint(x: width - cornerRadius, y: height - shapeYOffset - cornerRadius / 4))
        // top right corner
        path.addQuadCurve(to: CGPoint(x: width, y: height - shapeYOffset + cornerRadius), controlPoint: CGPoint(x: width, y: height - shapeYOffset))
        
        // bottom right point
        path.addLine(to: CGPoint(x: width, y: height - cornerRadius))
        // bottom right corner
        path.addQuadCurve(to: CGPoint(x: width - cornerRadius, y: height), controlPoint: CGPoint(x: width, y: height))
        
        // bottom left point
        path.addLine(to: CGPoint(x: cornerRadius, y: height))
        // bottom left corner
        path.addQuadCurve(to: CGPoint(x: 0, y: height - cornerRadius), controlPoint: CGPoint(x: 0, y: height))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = rect
        
        self.layer.mask = shapeLayer
        shapeLayer.path = path.cgPath
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
