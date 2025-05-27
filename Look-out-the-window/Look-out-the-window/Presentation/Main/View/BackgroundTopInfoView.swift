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
    
    private(set) var riveViewModel: RiveViewModel = RiveViewModel(fileName: "Cloudy", stateMachineName: "State Machine 1")
    
    // MARK: - UI Components
    /// Rive 날씨 아이콘
    lazy var loadingRiveView: RiveView = {
        let view = riveViewModel.createRiveView()
        view.preferredFramesPerSecond = 10
        view.isUserInteractionEnabled = false
        return view
    }()
    
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
        $0.font = .systemFont(ofSize: 80, weight: .light)
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
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(model: CurrentWeather) {
        city.text = model.address
        temperature.text = "\(model.temperature)°"
        weather.text = model.skyInfo
        highestTemp.text = "H:\(model.maxTemp)°"
        lowestTemp.text = "L:\(model.minTemp)°"
        
        self.riveViewModel = RiveViewModel(fileName: model.rive)
        riveViewModel.setView(loadingRiveView)
    }
}

// MARK: - Setting Methods
private extension BackgroundTopInfoView {
    func setupUI() {
        setViewHiearchy()
        setConstraints()
    }
    
    func setViewHiearchy() {
        self.addSubviews(infoStackView, loadingRiveView)
        infoStackView.addArrangedSubviews(city, temperature, weather, tempStackView)
        tempStackView.addArrangedSubviews(highestTemp, lowestTemp)
    }
    
    func setConstraints() {
        infoStackView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).inset(30)
            $0.centerX.equalToSuperview()
        }
        
        loadingRiveView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(infoStackView.snp.bottom)
            $0.width.height.equalTo(infoStackView.snp.height).multipliedBy(1.5)
        }
    }
}
