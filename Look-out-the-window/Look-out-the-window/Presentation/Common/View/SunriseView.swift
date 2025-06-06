//
//  SunriseView.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/23/25.
//

import UIKit
import SnapKit
import Then

/// `SunriseView`는 일출, 일몰, 현재 시간을 기반으로 태양의 위치를 시각적으로 표시하는 커스텀 뷰입니다.
/// - 일출 전(`dawn`), 낮(`day`), 일몰 후(`night`)를 각각 다른 곡선으로 표현
/// - 현재 시간에 따른 태양 위치를 계산하여 뷰에 그립니다
final class SunriseView: UIView {
    
    /// 새벽 구간의 베지어 곡선상 좌표 배열
    private var dawnPoints: [CGPoint] = []
    /// 낮 구간의 베지어 곡선상 좌표 배열
    private var dayPoints: [CGPoint] = []
    /// 밤 구간의 베지어 곡선상 좌표 배열
    /// 변경 시 `calculateSunPoint()`를 통해 현재 태양 위치 재계산
    private var nightPoints: [CGPoint] = [] {
        didSet {
            calculateSunPoint(currentTime: currentTime,
                              sunriseTime: sunriseTime,
                              sunsetTime: sunsetTime,
                              timeOffset: timeOffset
            )
            self.setNeedsDisplay()
        }
    }
    
    /// 현재 시간 (Unix Timestamp)
    private var currentTime: Int = 0
    /// 일출 시간 (Unix Timestamp)
    private var sunriseTime: Int = 0
    /// 일몰 시간 (Unix Timestamp)
    private var sunsetTime: Int = 0
    /// 타임 오프셋
    private var timeOffset: Int = 0
    /// 현재 태양이 위치할 좌표
    private lazy var currentSunPoint = CGPoint(x: 0, y: self.bounds.maxY / 1.5 + 10)
    
    /// ⚠️ 변경 : 라벨 2개로 축소, 명칭 변경
    let mainLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 32, weight: .bold)
    }
    let subLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 16, weight: .medium)
    }
    
    /// 생성자 - 현재 시간, 일출, 일몰 시간을 받아 초기 설정을 수행합니다
    /// ⚠️ 변경 : configure에서 mainLabel, subLabel만 세팅
    convenience init(currentTime: Int, sunriseTime: Int, sunsetTime: Int, timeOffset: Int) {
        self.init(frame: .zero)
        self.currentTime = currentTime
        self.sunriseTime = sunriseTime
        self.sunsetTime = sunsetTime
        self.timeOffset = timeOffset
    }
    
    /// 기본 생성자
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setupUI()
    }
    /// 스토리보드 사용 비활성화
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// draw 메서드 - 세 구간의 곡선과 태양의 현재 위치를 그림
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawDawnPath()
        drawDayPath()
        drawNightPath()
        drawHorizon()
        setSunPathPoints()
        drawCurrentSun(point: currentSunPoint)
    }
    
    /// 뷰 구성 - 라벨 값 설정
    /// - Parameters:
    ///   - currentTime: 현재 시간
    ///   - sunriseTime: 일출 시간
    ///   - sunsetTime: 일몰 시간
    /// ⚠️ 변경 : mainLabel, subLabel만 세팅 (일출/일몰 시간 포맷)
    func configure(currentTime: Int, sunriseTime: Int, sunsetTime: Int, timeOffset: Int) {
        self.currentTime = currentTime
        self.sunriseTime = sunriseTime
        self.sunsetTime = sunsetTime
        self.timeOffset = timeOffset
        
        let sunriseTimeUnix = Date(timeIntervalSince1970: TimeInterval(sunriseTime)).addingTimeInterval(TimeInterval(timeOffset)).timeIntervalSince1970
        let sunsetTimeUnix = Date(timeIntervalSince1970: TimeInterval(sunsetTime)).addingTimeInterval(TimeInterval(timeOffset)).timeIntervalSince1970

        let sunriseString = Int(sunriseTimeUnix).to12HourInt(timeOffset: timeOffset)
        let sunsetString = Int(sunsetTimeUnix).to12HourInt(timeOffset: timeOffset)

        if currentTime < sunriseTime {
            mainLabel.text = sunriseString
            subLabel.text = "일몰: \(sunsetString)"
        } else if currentTime < sunsetTime {
            mainLabel.text = sunriseString
            subLabel.text = "일몰: \(sunsetString)"
        } else {
            mainLabel.text = sunsetString
            subLabel.text = "일출: \(sunriseString)"
        }

        setSunPathPoints()
        self.setNeedsDisplay()
    }

    /// 현재 시간에 해당하는 태양 위치 좌표를 계산합니다
    private func calculateSunPoint(currentTime: Int, sunriseTime: Int, sunsetTime: Int, timeOffset: Int) {
        let current = Date(timeIntervalSince1970: TimeInterval(currentTime)).addingTimeInterval(TimeInterval(timeOffset)).timeIntervalSince1970
        guard let (startUnix, _) = currentTime.getUnixRange(unixTime: current, timeOffset: timeOffset) else { return }
        
        let sunrise = Date(timeIntervalSince1970: TimeInterval(sunriseTime)).addingTimeInterval(TimeInterval(timeOffset))
        let sunset = Date(timeIntervalSince1970: TimeInterval(sunsetTime)).addingTimeInterval(TimeInterval(timeOffset))
        
        // sunriseTime, sunsetTime, currentTime이 모두 같은 날 범위 내에 있는지 검증
        
        let startInteger = 0
        let endInteger = 86399
        let currentInteger = Int(current) - Int(startUnix)
        let sunriseInteger = Int(sunrise.timeIntervalSince1970) - Int(startUnix)
        let sunsetInteger = Int(sunset.timeIntervalSince1970) - Int(startUnix)
        
        if (startInteger..<sunriseInteger).contains(currentInteger) {
            let offset = Int(Double(currentInteger) / Double(sunriseInteger) * 100)
            self.currentSunPoint = dawnPoints[offset]
        } else if (sunriseInteger..<sunsetInteger).contains(currentInteger) {
            let offset = Int(Double(currentInteger) / Double(sunsetInteger) * 100)
            self.currentSunPoint = dayPoints[offset]
        } else if (sunsetInteger...endInteger).contains(currentInteger) {
            let offset = Int(Double(currentInteger) / Double(endInteger) * 100)
            self.currentSunPoint = nightPoints[offset]
        } else {
            print("SunriseView ERROR: 범위 없음")
        }
    }
    /// 새벽, 낮, 밤 구간에 대한 베지어 포인트를 계산하여 저장
    private func setSunPathPoints() {
        let dawnPoint = getDawnPoints()
        let dayPoint = getDayPoints()
        let nightPoint = getNightPoints()
        self.dawnPoints = calculateBezierPoints(
            start: dawnPoint.start,
            control1: dawnPoint.control1,
            control2: dawnPoint.control2,
            end: dawnPoint.end
        )
        self.dayPoints = calculateBezierPoints(
            start: dayPoint.start,
            control1: dayPoint.control1,
            control2: dayPoint.control2,
            end: dayPoint.end
        )
        self.nightPoints = calculateBezierPoints(
            start: nightPoint.start,
            control1: nightPoint.control1,
            control2: nightPoint.control2,
            end: nightPoint.end
        )
    }
    /// 주어진 베지어 곡선 정보를 기반으로 지정된 스텝 수만큼의 좌표를 계산합니다
    /// - Parameters:
    ///   - start: 시작점
    ///   - control1: 제어점 1
    ///   - control2: 제어점 2
    ///   - end: 끝점
    ///   - steps: 분할 갯수 (기본값: 100)
    /// - Returns: 곡선을 따라 분할된 CGPoint 배열
    private func calculateBezierPoints(start: CGPoint,
                                       control1: CGPoint,
                                       control2: CGPoint,
                                       end: CGPoint,
                                       steps: Int = 100) -> [CGPoint] {
        var points: [CGPoint] = []
        
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let x = pow(1 - t, 3) * start.x +
            3 * pow(1 - t, 2) * t * control1.x +
            3 * (1 - t) * pow(t, 2) * control2.x +
            pow(t, 3) * end.x
            
            let y = pow(1 - t, 3) * start.y +
            3 * pow(1 - t, 2) * t * control1.y +
            3 * (1 - t) * pow(t, 2) * control2.y +
            pow(t, 3) * end.y
            
            points.append(CGPoint(x: x, y: y))
        }
        
        return points
    }
}
// MARK: - UI Setup Methods
private extension SunriseView {
    /// 서브뷰를 추가하고 레이아웃을 구성합니다.
    func setupUI() {
        self.addSubviews(mainLabel, subLabel)
        configureLayout()
    }
    /// Auto Layout 제약을 설정합니다.
    func configureLayout() {
        mainLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(8)
        }
        subLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().inset(2)
        }
    }
    
}

// MARK: Drawing Methods
private extension SunriseView {
    /// 현재 태양 위치에 작은 원을 그립니다.
    /// - Parameter point: 태양의 중심 좌표
    func drawCurrentSun(point: CGPoint) {
        let sun = UIBezierPath()
        sun.move(to: point)
        sun.addArc(withCenter: point, radius: 2.5, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        UIColor.white.setFill()
        sun.stroke()
        sun.fill()
    }
    /// 수평선을 그립니다. y 좌표는 뷰 높이의 약 55%에 위치합니다.
    func drawHorizon() {
        let horizonPath = UIBezierPath()
        let horizonStartPoint = CGPoint(x: 0, y: self.bounds.maxY / 1.8)
        let horizonEndPoint = CGPoint(x: self.bounds.maxX, y: self.bounds.maxY / 1.8)
        horizonPath.move(to: horizonStartPoint)
        horizonPath.addLine(to: horizonEndPoint)
        horizonPath.lineWidth = 1.5
        UIColor.white.setStroke()
        horizonPath.stroke()
    }
    /// 새벽 구간의 곡선을 그립니다.
    func drawDawnPath() {
        let dawnPath = UIBezierPath()
        let points = getDawnPoints()
        dawnPath.move(to: points.start)
        dawnPath.addCurve(to: points.end, controlPoint1: points.control1, controlPoint2: points.control2)
        dawnPath.lineWidth = 2.5
        UIColor.systemGray4.setStroke()
        dawnPath.stroke()
        
    }
    /// 낮 구간의 곡선을 그립니다.
    func drawDayPath() {
        let dayPath = UIBezierPath()
        let points = getDayPoints()
        dayPath.move(to: points.start)
        dayPath.addCurve(to: points.end, controlPoint1: points.control1, controlPoint2: points.control2)
        dayPath.lineWidth = 2.5
        UIColor.lightGray.setStroke()
        dayPath.stroke()
        
    }
    /// 밤 구간의 곡선을 그립니다.
    func drawNightPath() {
        let nightPath = UIBezierPath()
        let points = getNightPoints()
        nightPath.move(to: points.start)
        nightPath.addCurve(to: points.end, controlPoint1: points.control1, controlPoint2: points.control2)
        nightPath.lineWidth = 2.5
        UIColor.systemGray4.setStroke()
        nightPath.stroke()
    }
}

// MARK: - Bezier Path Control Points
private extension SunriseView {
    /// 새벽 구간의 베지어 곡선을 위한 포인트들을 반환합니다.
    /// - Returns: 시작점, 제어점1, 제어점2, 끝점 튜플
    func getDawnPoints() -> (start: CGPoint, control1: CGPoint, control2: CGPoint, end: CGPoint) {
        let dawnStartPoint = CGPoint(x: 0, y: self.bounds.maxY / 1.8 + 10)
        let dawnEndPoint = CGPoint(x: self.bounds.maxX / 4, y: self.bounds.maxY / 1.8)
        let controlPoint1 = CGPoint(x: self.bounds.maxX / 4 - 30, y: self.bounds.maxY / 1.8 + 10)
        let controlPoint2 = CGPoint(x: self.bounds.maxX / 4 - 15, y: self.bounds.maxY / 1.8 + 10)
        return (dawnStartPoint, controlPoint1, controlPoint2, dawnEndPoint)
    }
    /// 낮 구간의 베지어 곡선을 위한 포인트들을 반환합니다.
    /// - Returns: 시작점, 제어점1, 제어점2, 끝점 튜플
    func getDayPoints() -> (start: CGPoint, control1: CGPoint, control2: CGPoint, end: CGPoint) {
        let dayStartPoint = CGPoint(x: self.bounds.maxX / 4, y: self.bounds.maxY / 1.8)
        let dayEndPoint = CGPoint(x: self.bounds.maxX / 4 * 3, y: self.bounds.maxY / 1.8)
        let controlPoint1 = CGPoint(x: self.bounds.midX - 10, y: self.bounds.midY / 1.3)
        let controlPoint2 = CGPoint(x: self.bounds.midX + 10, y: self.bounds.midY / 1.3)
        return (dayStartPoint, controlPoint1, controlPoint2, dayEndPoint)
    }
    /// 밤 구간의 베지어 곡선을 위한 포인트들을 반환합니다.
    /// - Returns: 시작점, 제어점1, 제어점2, 끝점 튜플
    func getNightPoints() -> (start: CGPoint, control1: CGPoint, control2: CGPoint, end: CGPoint) {
        let nightStartPoint = CGPoint(x: self.bounds.maxX / 4 * 3, y: self.bounds.maxY / 1.8)
        let nightEndPoint = CGPoint(x: self.bounds.maxX, y: self.bounds.maxY / 1.8 + 10)
        let controlPoint1 = CGPoint(x: (self.bounds.maxX / 4 * 3) + 15, y: self.bounds.maxY / 1.8 + 10)
        let controlPoint2 = CGPoint(x: (self.bounds.maxX / 4 * 3) + 30, y: self.bounds.maxY / 1.8 + 10)
        return (nightStartPoint, controlPoint1, controlPoint2, nightEndPoint)
    }
}
