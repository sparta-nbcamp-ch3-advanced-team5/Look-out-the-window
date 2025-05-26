//
//  HourlyCell.swift
//  Look-out-the-window
//
//  Created by GO on 5/21/25.
//

import UIKit

final class HourlyCell: UICollectionViewCell {
    static let id = "HourlyCell"
    
    private let hourLabel = UILabel().then {
        $0.text = "9PM"
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .monospacedDigitSystemFont(ofSize: 16, weight: .bold)
    }
    
    private let weatherIcon = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.image = UIImage(systemName: "sun.max")
    }
    
    private let tempLabel = UILabel().then {
        $0.text = "18'C"
        $0.textAlignment = .center
        $0.font = .monospacedDigitSystemFont(ofSize: 18, weight: .bold)
        $0.textColor = .white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(model: HourlyModel, isFirst: Bool) {
        hourLabel.text = isFirst ? "Now" : String(format: "%02d시", model.hour)
        let config = UIImage.SymbolConfiguration.preferringMulticolor()
        weatherIcon.image = UIImage(systemName: model.weatherInfo, withConfiguration: config)
        tempLabel.text = model.temperature
    }
}

private extension HourlyCell {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.backgroundColor = .clear
    }
    
    func setViewHierarchy() {
        self.addSubviews(hourLabel, weatherIcon, tempLabel)
    }
    
    func setConstraints() {
        hourLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        weatherIcon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.size.equalTo(25)
            $0.top.equalTo(hourLabel.snp.bottom).offset(4)
        }
        
        tempLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(weatherIcon.snp.bottom).offset(4)
        }
    }
}
