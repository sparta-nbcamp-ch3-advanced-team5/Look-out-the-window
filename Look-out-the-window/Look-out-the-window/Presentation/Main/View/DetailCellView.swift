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
        $0.font = .systemFont(ofSize: 36, weight: .semibold)
        $0.textColor = .white
    }

    private let subTitleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .white
        $0.text = "in last 24h"
    }

    private let bottomLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .light)
        $0.textColor = .white
        $0.numberOfLines = 0
        $0.text = "Test Test Test"
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
            subTitleLabel.text = "체감온도"
            bottomLabel.text = ""
        case .humidity:
            mainValueLabel.text = "\(model.value)%"
            subTitleLabel.text = "습도"
            bottomLabel.text = ""
        case .uvIndex:
            mainValueLabel.text = model.value
            subTitleLabel.text = "자외선지수"
            bottomLabel.text = "UV 정보는 실시간으로 변동될 수 있습니다."
        case .visibility:
            if let meter = Double(model.value) {
                let km = meter / 1000.0
                // 소수점 한 자리까지 표시 (예: "10.0 Km")
                mainValueLabel.text = String(format: "%.1f Km", km)
            } else {
                mainValueLabel.text = "\(model.value) m"
            }
            subTitleLabel.text = "가시거리"
            bottomLabel.text = ""
        case .rainSnow:
            mainValueLabel.text = model.value
            subTitleLabel.text = "강수량/적설량"
            bottomLabel.text = "최근 24시간 기준"
        case .clouds:
            mainValueLabel.text = "\(model.value)%"
            subTitleLabel.text = "구름량"
            bottomLabel.text = ""
        default:
            mainValueLabel.text = model.value
            subTitleLabel.text = ""
            bottomLabel.text = ""
        }
    }

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
        self.addSubviews(mainValueLabel, subTitleLabel, bottomLabel)
    }
    
    func viewConstraints() {
        mainValueLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(10)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(mainValueLabel.snp.top).offset(50)
            $0.leading.equalToSuperview().offset(10)
        }
        
        bottomLabel.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.top).offset(60)
            $0.leading.equalToSuperview().offset(10)
        }
    }
}
