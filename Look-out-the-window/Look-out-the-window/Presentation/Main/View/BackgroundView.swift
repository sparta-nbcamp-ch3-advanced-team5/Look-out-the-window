//
//  BackgroundView.swift
//  Look-out-the-window
//
//  Created by 정근호 on 5/20/25.
//

import UIKit

import SnapKit
import Then
import RiveRuntime

final class BackgroundView: UIView {
    
    private(set) var weatherInfo: WeatherInfo
    private(set) var riveViewModel: RiveViewModel
    
    // MARK: - UI Components
    private lazy var riveView = RiveView()
    
    private lazy var infoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .center
        $0.spacing = 0
    }
    
    private lazy var city = UILabel().then {
        $0.text = "부산광역시"
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 30, weight: .medium)
        $0.textColor = .label
    }
    
    private lazy var temperature = UILabel().then {
        $0.text = "20°"
        $0.font = .systemFont(ofSize: 90, weight: .light)
        $0.textColor = .label
    }
    
    private lazy var weather = UILabel().then {
        $0.text = "흐림"
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.textColor = .secondaryLabel
    }
    
    private lazy var tempStackView = UIStackView().then() {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.spacing = 8
    }
    
    private lazy var highestTemp = UILabel().then {
        $0.text = "H:24°"
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.textColor = .label
    }
    
    private lazy var lowestTemp = UILabel().then {
        $0.text = "L:18°"
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.textColor = .label
    }
    
    
    // MARK: - Initializer
    init(frame: CGRect, weatherInfo: WeatherInfo) {
        self.weatherInfo = weatherInfo
        self.riveViewModel = RiveViewModel(fileName: weatherInfo.rive , stateMachineName: "State Machine 1")
        
        super.init(frame: frame)
        
        applyGradientBackground(time: weatherInfo.time)
        
        self.riveView = riveViewModel.createRiveView()
        city.text = weatherInfo.city
        temperature.text = "\(weatherInfo.temperature)°"
        weather.text = weatherInfo.weather
        highestTemp.text = "H:\(weatherInfo.highestTemp)°"
        lowestTemp.text = "L:\(weatherInfo.lowestTemp)°"
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.sublayers?.first(where: { $0 is CAGradientLayer })?.frame = self.bounds
    }
    
    // MARK: - UI & Layout
    private func setupUI() {
        self.addSubviews(infoStackView, riveView)
        infoStackView.addArrangedSubviews(city, temperature, weather, tempStackView)
        tempStackView.addArrangedSubviews(highestTemp, lowestTemp)
        
        infoStackView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).inset(50)
            $0.centerX.equalToSuperview()
        }
        
        riveView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(infoStackView.snp.bottom)
            $0.width.height.equalTo(500)
        }
    }
    
    private func applyGradientBackground(time: Double) {
        let newStartPoint = normalize(time, originMin: 0.0, originMax: 10.0)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ UIColor.mainBackground1.cgColor, UIColor.secondaryBackground.cgColor ]
        gradientLayer.startPoint = CGPoint(x: newStartPoint, y: newStartPoint)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
//        gradientLayer.locations = [0.4, 0.6]
        gradientLayer.frame = self.bounds
        // 배경이니 제일 하단에 위치하도록
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func normalize(_ value: Double, originMin: Double, originMax: Double) -> Double {
        let targetMin = 0.0
        let targetMax = 1.0
        
        let ratio = (value - originMin) / (originMax - originMin)
        
        let scaledValue = targetMin + ratio * (targetMax - targetMin)
        
        let clampedValue = max(targetMin, min(scaledValue, targetMax))

        print(value, clampedValue)
        return clampedValue
    }
}
