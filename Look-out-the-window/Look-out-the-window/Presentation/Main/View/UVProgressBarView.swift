//
//  UVProgressBarView.swift
//  Look-out-the-window
//
//  Created by GO on 5/23/25.
//

import UIKit
import SnapKit

final class UVProgressBarView: UIView {
    
    private let backgroundBar = UIView()
    private let indicator = UIView()
    
    private var indicatorLeadingConstraint: Constraint?
    
    var progress: CGFloat = 0 {
        didSet {
            updateIndicatorPosition()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundBar.layer.sublayers?.first?.frame = backgroundBar.bounds
        updateIndicatorPosition()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateIndicatorPosition() {
        layoutIfNeeded()
        let totalWidth = backgroundBar.bounds.width
        let clampedProgress = max(0, min(progress, 1))
        let indicatorX = clampedProgress * totalWidth - 3  // 반지름 고려해서 offset 보정

        indicatorLeadingConstraint?.update(offset: indicatorX)
    }
}


private extension UVProgressBarView {
    func setupUI() {
        setAppearance()
        viewHierarchy()
        viewConstraints()
    }
    
    func setAppearance() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemGreen.cgColor,
                                UIColor.systemYellow.cgColor,
                                UIColor.systemOrange.cgColor,
                                UIColor.systemPink.cgColor,
                                UIColor.systemPurple.cgColor]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 2
        backgroundBar.layer.insertSublayer(gradientLayer, at: 0)
        
        indicator.backgroundColor = .white
        indicator.layer.cornerRadius = 4
        indicator.layer.shadowColor = UIColor.black.cgColor
        indicator.layer.shadowOpacity = 0.3
        indicator.layer.shadowOffset = CGSize(width: 0, height: 1)
        indicator.layer.shadowRadius = 1
        
        layoutIfNeeded()
        gradientLayer.frame = backgroundBar.bounds
    }
    
    func viewHierarchy() {
        addSubviews(backgroundBar, indicator)
    }
    
    func viewConstraints() {
        backgroundBar.snp.makeConstraints{
            $0.edges.equalToSuperview()
            $0.height.equalTo(4)
        }
        
        indicator.snp.makeConstraints {
            $0.centerY.equalTo(backgroundBar)
            $0.size.equalTo(6)
            self.indicatorLeadingConstraint = $0.leading.equalToSuperview().constraint
        }
    }
}
