//
//  UVProgressBarView.swift
//  Look-out-the-window
//
//  Created by GO on 5/23/25.
//

import UIKit
import SnapKit
import Then

// 자외선 지수 분류
enum UVIndexLevel: String {
    case low = "낮음"
    case moderate = "보통"
    case high = "높음"
    case veryHigh = "매우 높음"
    case extreme = "위험"

    static func level(for uvi: Int) -> UVIndexLevel {
        switch uvi {
        case 0...2:      return .low
        case 3...5:      return .moderate
        case 6...7:      return .high
        case 8...10:     return .veryHigh
        default:         return .extreme
        }
    }
}

final class UVProgressBarView: UIView {
    
    private let numberLabel = UILabel().then {
        $0.text = "0 ~ 100"
        $0.textAlignment = .center
        $0.textColor = .white
        $0.font = .monospacedDigitSystemFont(ofSize: 40, weight: .bold)
    }
    private let stateLabel = UILabel().then {
        $0.text = "낮음"
        $0.textAlignment = .center
        $0.textColor = .white
        $0.font = .monospacedDigitSystemFont(ofSize: 20, weight: .semibold)
    }
    
    private let backgroundBar = UIView()
    private let indicator = UIView()
    
    // indicator의 leading 위치를 제어하는 Constraint 객체를 저장 - Snapkit 활용
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

        // indicator의 leading 제약조건 update -> indicatorX
        indicatorLeadingConstraint?.update(offset: indicatorX)
    }
    
    func updateUI(with uvi: Int) {
        let level = UVIndexLevel.level(for: uvi)
        numberLabel.text = String(uvi)
        stateLabel.text = level.rawValue
        progress = CGFloat(min(max(Double(uvi) / 11.0, 0), 1))
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
        addSubviews(numberLabel, stateLabel, backgroundBar, indicator)
    }
    
    func viewConstraints() {
        numberLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(4)
        }
        
        stateLabel.snp.makeConstraints {
            $0.top.equalTo(numberLabel.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(4)
        }
        
        backgroundBar.snp.makeConstraints {
            $0.top.equalTo(stateLabel.snp.bottom).offset(40)
            $0.directionalHorizontalEdges.equalToSuperview().inset(4)
            $0.height.equalTo(4)
        }
        
        indicator.snp.makeConstraints {
            $0.centerY.equalTo(backgroundBar)
            $0.size.equalTo(6)
            // 저장된 leading 제약조건 적용
            self.indicatorLeadingConstraint = $0.leading.equalToSuperview().constraint
        }
    }
}
