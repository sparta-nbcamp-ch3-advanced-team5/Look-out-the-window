//
//  RegionWeatherCell.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/22/25.
//

import UIKit

import RiveRuntime
import SnapKit
import Then

/// 지역 날씨 리스트 `UICollectionViewCell`
final class RegionWeatherCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "RegionWeatherCell"
    
    private var riveViewModel = RiveViewModel(fileName: Rive.partlyCloudy)
        
    // MARK: - UI Components
    
    private let currTempLabel = UILabel().then {
        $0.text = "20°"
        $0.textColor = .label
        $0.font = .monospacedDigitSystemFont(ofSize: 64, weight: .regular)
    }
    
    private let highTempLabel = UILabel().then {
        $0.text = "H: --°"
        $0.textColor = .secondaryLabel
        $0.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    }
    
    private let lowTempLabel = UILabel().then {
        $0.text = "L: --°"
        $0.textColor = .secondaryLabel
        $0.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    }
    
    private let highLowTempStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 2
    }
    
    private let locationLabel = UILabel().then {
        $0.text = "Toronto, Canada"
        $0.textColor = .label
        $0.font = .systemFont(ofSize: 17)
    }
    
    private let tempAndLocationStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 2
    }
    
    private let riveView = RiveView()
    
    private let weatherLabel = UILabel().then {
        $0.text = "--"
        $0.textColor = .label
        $0.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    }
    
    private let lastUpdateLabel = UILabel().then {
        $0.text = "업데이트: -/- -:--"
        $0.textColor = .secondaryLabel
        $0.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
    }
    
    private let weatherAndUpdateStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .trailing
        $0.spacing = 2
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setGradient()
    }
    
    // MARK: - Methods
    
    func configure(model: CurrentWeather) {
        currTempLabel.text = "\(model.temperature)°"
        highTempLabel.text = "H: \(model.maxTemp)°"
        lowTempLabel.text = "L: \(model.minTemp)°"
        locationLabel.text = model.address
        riveViewModel = RiveViewModel(fileName: model.rive)
        riveViewModel.setView(riveView)
        weatherLabel.text = model.skyInfo
        lastUpdateLabel.text = "업데이트 \(model.currentTime.convertUnixToHourMinuteAndMark())"
        // TODO: M/d a h:mm 포맷 반영
    }
}

// MARK: - UI Methods

private extension RegionWeatherCell {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.backgroundColor = .clear
        self.riveView.preferredFramesPerSecond = 10
        self.riveView.isUserInteractionEnabled = false
    }
    
    func setViewHierarchy() {
        self.contentView.addSubviews(currTempLabel, riveView,
                                     tempAndLocationStackView, weatherAndUpdateStackView)
        
        tempAndLocationStackView.addArrangedSubviews(highLowTempStackView,
                                                     locationLabel)
        
        highLowTempStackView.addArrangedSubviews(highTempLabel, lowTempLabel)
        
        weatherAndUpdateStackView.addArrangedSubviews(weatherLabel,
                                                      lastUpdateLabel)
    }
    
    func setConstraints() {
        currTempLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(40)
            $0.leading.equalToSuperview().inset(20)
        }
        
        riveView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(-85)
            $0.trailing.equalToSuperview().inset(-80)
            $0.width.height.equalTo(350)
        }
        
        tempAndLocationStackView.snp.makeConstraints {
            $0.leading.equalTo(currTempLabel)
            $0.bottom.equalToSuperview().inset(20)
            $0.width.greaterThanOrEqualTo(180)
        }
        
        highLowTempStackView.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        
        weatherAndUpdateStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(tempAndLocationStackView)
        }
    }
    
    func setGradient() {
        self.backgroundView = RegionWeatherCellBGView(frame: self.frame)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        let colors: [CGColor] = [
            UIColor.cellStart.cgColor,
            UIColor.cellEnd.cgColor
        ]
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        
        self.backgroundView?.layer.addSublayer(gradientLayer)
    }
}
