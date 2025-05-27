//
//  DetailCellView.swift
//  Look-out-the-window
//
//  Created by GO on 5/25/25.
//

import UIKit
import SnapKit
import Then

final class DetailCellView: UIView {
    
    private let mainValueLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 40, weight: .bold)
        $0.textColor = .white
    }
    
    private let bottomLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = .white
        $0.numberOfLines = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(model: DetailModel) {
        switch model.title {
        case .feelsLike:
            mainValueLabel.text = "\(model.value)°"
            // model.value: 체감온도, model.someData: 현재온도
            if let feels = Double(model.value),
               let current = Double(model.someData) {
                let diff = current - feels
                if diff > 0 {
                    bottomLabel.text = "체감상 시원하게 느껴집니다"
                } else if diff < 0 {
                    bottomLabel.text = "체감상 더 덥게 느껴집니다"
                } else {
                    bottomLabel.text = "실제 온도와 비슷하게 느껴집니다"
                }
            } else {
                bottomLabel.text = ""
            }
            
        case .humidity:
            mainValueLabel.text = "\(model.value)%"
            if let humidity = Double(model.value) {
                switch humidity {
                case ..<40:
                    bottomLabel.text = "공기가 건조해요. 실내 습도 관리에 신경 써주세요"
                case 40..<60:
                    bottomLabel.text = "쾌적한 습도입니다"
                case 60..<80:
                    bottomLabel.text = "다소 습하게 느껴질 수 있어요"
                default:
                    bottomLabel.text = "공기가 매우 습해요. 환기에 신경 써주세요"
                }
            } else {
                bottomLabel.text = ""
            }

        case .visibility:
            if let meter = Double(model.value) {
                let km = meter / 1000.0
                mainValueLabel.text = String(format: "%.1f Km", km)
                // 가시거리 등급 표시
                let level: String
                switch km {
                case ..<1:
                    level = "매우 나쁨"
                case 1..<4:
                    level = "나쁨"
                case 4..<10:
                    level = "보통"
                case 10..<20:
                    level = "좋음"
                default:
                    level = "매우 좋음"
                }
                bottomLabel.text = "현재 가시거리 \(level)"
            } else {
                mainValueLabel.text = "\(model.value) m"
                bottomLabel.text = ""
            }
            
        case .rainSnow:
            mainValueLabel.text = model.value
            // someData: "비/눈" (예: "0.5/0.0")
            let rainSnowArr = model.someData.components(separatedBy: "/")
            if rainSnowArr.count == 2,
               let rain = Double(rainSnowArr[0].trimmingCharacters(in: .whitespaces)),
               let snow = Double(rainSnowArr[1].trimmingCharacters(in: .whitespaces)) {
                if rain > 0 {
                    bottomLabel.text = "1시간 이내 \(rain)mm의 비가 예상됩니다"
                } else if snow > 0 {
                    bottomLabel.text = "1시간 이내 \(snow)mm의 눈이 예상됩니다"
                } else {
                    bottomLabel.text = "예정된 예보가 없습니다"
                }
            } else {
                bottomLabel.text = "예정된 예보가 없습니다"
            }
            
            
        case .clouds:
            mainValueLabel.text = "\(model.value)%"
            bottomLabel.text = ""
            
        default:
            mainValueLabel.text = model.value
            bottomLabel.text = ""
        }    }
    
}

private extension DetailCellView {
    func setupUI() {
        setAppearance()
        viewHierarchy()
        viewConstraints()
    }
    
    func setAppearance() {
        self.backgroundColor = .clear
    }
    
    func viewHierarchy() {
        self.addSubviews(mainValueLabel, bottomLabel)
    }
    
    func viewConstraints() {
        mainValueLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(30)
        }
        
        bottomLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20)
            $0.centerX.equalToSuperview()
            $0.directionalHorizontalEdges.equalToSuperview().inset(4)
        }
    }
}
