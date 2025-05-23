//
//  ProgressBarView.swift
//  Look-out-the-window
//
//  Created by GO on 5/22/25.
//

import UIKit
import SnapKit

// 오늘 날씨에만 현재 온도 위치 마크해주기
final class ProgressBarView: UIView {
    
    private let baseView = UIView()
    private let rangeView = UIView()
    
    // 해당 날짜의 온도
    var maxTemp = 0
    var minTemp = 0
    
    // 전체 구간의 온도
    var totalMaxTemp = 0
    var totalMinTemp = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateProgress() {
        layoutIfNeeded() // 레이아웃 변경사항 즉시 적용
        let totalRange = CGFloat(totalMaxTemp - totalMinTemp) // 전체 범위
        guard totalRange > 0 else { return }
        
        // 위치 비율로 환산
        let minRatio = CGFloat(minTemp - totalMinTemp) / totalRange
        let maxRatio = CGFloat(maxTemp - totalMinTemp) / totalRange
        
        let barWidth = baseView.frame.width // 전체 기간 온도 범위의 길이
        let startX = barWidth * minRatio // 하루기준 최저온도 (rangeView 시작점)
        let rangeWidth = barWidth * (maxRatio - minRatio) // rangeView의 width
        
        // x에서 시작해서 rangeWidth까지만 적용 (rangeView)
        rangeView.frame = CGRect(x: startX, y: 0, width: rangeWidth, height: baseView.frame.height)
    }
}

private extension ProgressBarView {
    func setupUI() {
        setAppearance()
        viewHierarchy()
        viewConstraints()
    }
    
    func setAppearance() {
        baseView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        rangeView.backgroundColor = .systemYellow
    }
    
    func viewHierarchy() {
        addSubview(baseView)
        baseView.addSubview(rangeView)
    }
    
    func viewConstraints() {
        baseView.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(5)
        }
    }
}
