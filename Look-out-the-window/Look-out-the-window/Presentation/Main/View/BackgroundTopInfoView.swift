//
//  BackgroundTopInfoView.swift
//  Look-out-the-window
//
//  Created by 정근호 on 5/20/25.
//

import UIKit

import SnapKit
import Then
import RiveRuntime

/// 상단 날씨 요약 정보, Rive 날씨 아이콘
final class BackgroundTopInfoView: UIView {
    
    private(set) var weatherInfo: WeatherInfo
    private(set) var riveViewModel: RiveViewModel
    
    // MARK: - UI Components
    /// Rive 날씨 아이콘
    private lazy var riveView = RiveView()
    
    private lazy var infoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .center
        $0.spacing = 0
    }
    
    private lazy var city = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 30, weight: .medium)
        $0.textColor = .label
    }
    
    private lazy var temperature = UILabel().then {
        $0.font = .systemFont(ofSize: 90, weight: .light)
        $0.textColor = .label
    }
    
    private lazy var weather = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.textColor = .secondaryLabel
    }
    
    private lazy var tempStackView = UIStackView().then() {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.spacing = 8
    }
    
    private lazy var highestTemp = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.textColor = .label
    }
    
    private lazy var lowestTemp = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.textColor = .label
    }
    
    
    // MARK: - Initializer
    init(frame: CGRect, weatherInfo: WeatherInfo) {
        self.weatherInfo = weatherInfo
        // riveViewModel 생성, stateMachineName: Rive 파일의 애니메이션 네임
        // 자동재생 false
        self.riveViewModel = RiveViewModel(fileName: weatherInfo.rive , stateMachineName: "State Machine 1", autoPlay: false)
        
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setting Methods
private extension BackgroundTopInfoView {
    func setupUI() {
        setAppearance()
        setViewHiearchy()
        setConstraints()
    }
    
    func setAppearance() {
        city.text = weatherInfo.city
        temperature.text = "\(weatherInfo.temperature)°"
        weather.text = weatherInfo.weather
        highestTemp.text = "H:\(weatherInfo.highestTemp)°"
        lowestTemp.text = "L:\(weatherInfo.lowestTemp)°"
    }
    
    func setViewHiearchy() {
        // riveView 생성
        self.riveView = riveViewModel.createRiveView()
        self.riveView.preferredFramesPerSecond = 10
        self.riveView.isUserInteractionEnabled = false
        self.addSubviews(infoStackView, riveView)
        infoStackView.addArrangedSubviews(city, temperature, weather, tempStackView)
        tempStackView.addArrangedSubviews(highestTemp, lowestTemp)
    }
    
    func setConstraints() {
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
}
