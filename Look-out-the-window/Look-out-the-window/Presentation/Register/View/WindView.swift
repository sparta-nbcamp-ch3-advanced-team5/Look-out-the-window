//
//  WindView.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/22/25.
//

import UIKit
import SnapKit
import Then

/// 바람의 방향과 속도를 시각적으로 나타내는 원형 컴퍼스 뷰입니다.
/// - 중심에는 풍속이 표시되고, 원형 점선과 방향 선, 화살표가 함께 표시됩니다.
/// - 동서남북 방향 텍스트가 배치되며, 입력된 `degree` 값(각도)에 따라 선과 화살표가 표시됩니다.
final class WindView: UIView {
    
    /// 바람이 불어오는 방향을 나타내는 각도 (0~360도)
    var degree: CGFloat = 0
    /// 원형 컴퍼스의 반지름
    var radius: CGFloat = 0
    
    // MARK: 방향 표시 레이블 (동서남북)
    private let eastLabel = UILabel().then {
        $0.text = "E"
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .gray
    }
    
    private let westLabel = UILabel().then {
        $0.text = "W"
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .gray
    }
    
    private let southLabel = UILabel().then {
        $0.text = "S"
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .gray
    }
    
    private let northLabel = UILabel().then {
        $0.text = "N"
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .gray
    }
    
    /// 중심에 표시되는 풍속 레이블 (예: 9 km/h)
    private let windSpeedLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private let unitLabel = UILabel().then {
        $0.text = "km/h"
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    /// degree 및 radius 값을 초기 설정하고 뷰를 다시 그립니다.
    convenience init(degree: CGFloat, radius: CGFloat, speed: Double) {
        self.init(frame: .zero)
        self.degree = degree
        self.radius = radius
        self.windSpeedLabel.text = "\(Int(round(speed)))"
        self.setNeedsDisplay()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// 뷰가 다시 그려질 때 호출되어, 바람 방향을 포함한 UI를 그립니다.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawPaths()
    }
}

// MARK: Setup Methods
private extension WindView {
    /// 레이블 및 UI 요소들을 서브뷰에 추가합니다.
    func setupUI() {
        self.addSubviews(eastLabel, westLabel, southLabel, northLabel, windSpeedLabel, unitLabel)
        configureLayout()
    }
    /// 오토레이아웃 제약 조건을 설정합니다.
    func configureLayout() {
        eastLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(15)
        }
        westLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(15)
        }
        southLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(15)
        }
        northLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(15)
        }
        windSpeedLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-12)
        }
        unitLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(windSpeedLabel.snp.bottom).offset(-5)
        }
    }
}

// MARK: Draw BezierPaths
private extension WindView {
    /// 원형 점선과 방향 선 등을 포함한 전체 경로를 그립니다.
    func drawPaths() {
        // cell의 크기에 따라 동적으로 계산
        self.radius = min(bounds.width, bounds.height) / 2 - 10 // 여백 조정
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let circlePath = UIBezierPath(arcCenter: center,
                                      radius: radius,
                                      startAngle: 0,
                                      endAngle: CGFloat.pi * 2,
                                      clockwise: true)
        circlePath.setLineDash([2,2], count: 2, phase: 0)
        circlePath.lineWidth = 8
        UIColor.gray.setStroke()
        circlePath.stroke()
        
        drawLine(center: center)
        
    }
    /// 주어진 중심점에서 바람 방향에 따라 선을 그립니다.
    func drawLine(center: CGPoint) {
        let radians = degree * CGFloat.pi / 180
        let oppsiteDegree: CGFloat = CGFloat((Int(degree) + 180) % 360)
        let oppsiteRadians = oppsiteDegree * CGFloat.pi / 180
        let endPoint = CGPoint(x: center.x + (radius + 2) * cos(radians),
                               y: center.y + (radius + 2) * sin(radians))
        let endMiddlePoint = CGPoint(x: center.x + 30 * cos(radians),
                                     y: center.y + 30 * sin(radians))
        let endPointLinePoint = CGPoint(x: center.x + (radius + 2) * cos(radians),
                                        y: center.y + (radius + 2) * sin(radians))
        let oppsitePoint = CGPoint(x: center.x + radius * cos(oppsiteRadians),
                                   y: center.y + radius * sin(oppsiteRadians))
        let oppsiteMiddlePoint = CGPoint(x: center.x + 30 * cos(oppsiteRadians),
                                         y: center.y + 30 * sin(oppsiteRadians))
        let oppsiteLineEndPoint = CGPoint(x: center.x + (radius - 4) * cos(oppsiteRadians),
                                          y: center.y + (radius - 4) * sin(oppsiteRadians))
        
        let linePath = UIBezierPath()
        UIColor.white.setStroke()
        UIColor.clear.setFill()
        linePath.lineWidth = 3
        linePath.move(to: endMiddlePoint)
        linePath.addLine(to: endPointLinePoint)
        linePath.move(to: oppsiteMiddlePoint)
        linePath.addLine(to: oppsiteLineEndPoint)
        linePath.stroke()
        linePath.lineWidth = 1.5
        linePath.addArc(withCenter: oppsitePoint, radius: 3.5, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        linePath.stroke()
        
        drawArrowHead(start: center, end: endPoint)
    }
    /// 바람이 불어가는 방향의 끝점에 화살표 머리를 그립니다.
    func drawArrowHead(start: CGPoint, end: CGPoint) {
        let arrowAngle: CGFloat = CGFloat.pi / 9
        
        let dx = end.x - start.x
        let dy = end.y - start.y
        let lineAngle = atan2(dy, dx)
        
        let leftAngle = lineAngle + CGFloat.pi - arrowAngle
        let leftPoint = CGPoint(x: end.x + 8 * cos(leftAngle),
                                y: end.y + 8 * sin(leftAngle)
        )
        
        let rightAngle = lineAngle + CGFloat.pi + arrowAngle
        let rightPoint = CGPoint(x: end.x + 8 * cos(rightAngle),
                                 y: end.y + 8 * sin(rightAngle)
        )
        
        let arrowPath = UIBezierPath()
        arrowPath.lineCapStyle = .round
        arrowPath.move(to: end)
        arrowPath.addLine(to: rightPoint)
        arrowPath.move(to: end)
        arrowPath.addLine(to: leftPoint)
        arrowPath.lineWidth = 2.5
        arrowPath.stroke()
        UIColor.white.setStroke()
    }
}

extension WindView {
    /// 바람 각도(degree)와 풍속(speed)를 넣어주면 뷰를 갱신
    func bind(degree: CGFloat, speed: Double) {
        self.degree = degree
        self.windSpeedLabel.text = "\(Int(round(speed)))"
        // radius는 draw에서 bounds 기반으로 계산 (별도 지정 불필요)
        setNeedsDisplay()
    }
}
