//
//  ProgressBarView.swift
//  Look-out-the-window
//
//  Created by GO on 5/22/25.
//

import SnapKit
import UIKit

final class ProgressBarView: UIView {
    
    private let baseView = UIView()
    private let rangeView = UIView()
    
    private let gradientLayer = CAGradientLayer()
    
    private let indicatorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // indicator -> currentTemp 인자 추가 (기본 nil)
    func updateProgress(minTemp: Int, maxTemp: Int, totalMinTemp: Int, totalMaxTemp: Int, currentTemp: Int? = nil) {
        layoutIfNeeded()  // 레이아웃 변경사항 즉시 적용
        let totalRange = CGFloat(totalMaxTemp - totalMinTemp)  // 전체 범위
        guard totalRange > 0 else { return }
        
        // 위치 비율로 환산
        let minRatio = CGFloat(minTemp - totalMinTemp) / totalRange
        let maxRatio = CGFloat(maxTemp - totalMinTemp) / totalRange
        
        let barWidth = baseView.frame.width  // 전체 기간 온도 범위의 길이
        let startX = barWidth * minRatio  // 하루기준 최저온도 (rangeView 시작점)
        let rangeWidth = barWidth * (maxRatio - minRatio)  // rangeView의 width
        
        // x에서 시작해서 rangeWidth까지만 적용 (rangeView)
        rangeView.frame = CGRect(x: startX, y: 0, width: rangeWidth, height: baseView.frame.height)
        gradientLayer.frame = rangeView.bounds  // gradientLayer도 같이 업데이트
        
        // 인디케이터 처리
        if let currentTemp = currentTemp {
            let currentRatio = CGFloat(currentTemp - totalMinTemp) / totalRange
            let indicatorX = barWidth * currentRatio - 4 // 인디케이터 width의 절반만큼 보정
            indicatorView.isHidden = false
            indicatorView.frame = CGRect(x: indicatorX, y: -3, width: 8, height: baseView.frame.height + 6)
        } else {
            indicatorView.isHidden = true
        }
    }
}

private extension ProgressBarView {
    func setupUI() {
        setAppearance()
        viewHierarchy()
        viewConstraints()
        setupGradient()
    }
    
    func setAppearance() {
        baseView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        rangeView.backgroundColor = .clear
        
        indicatorView.backgroundColor = .white
        indicatorView.layer.cornerRadius = 4
        indicatorView.isHidden = true // 기본적으로 숨김
    }
    
    func viewHierarchy() {
        addSubview(baseView)
        baseView.addSubviews(rangeView, indicatorView)
    }
    
    func viewConstraints() {
        baseView.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(5)
        }
    }
    
    func setupGradient() {
        gradientLayer.colors = [
            UIColor.systemYellow.cgColor,
            UIColor.systemOrange.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        rangeView.layer.insertSublayer(gradientLayer, at: 0)
    }
}
