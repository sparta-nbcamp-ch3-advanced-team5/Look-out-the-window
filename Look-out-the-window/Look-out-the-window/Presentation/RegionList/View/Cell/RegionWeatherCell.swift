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

/// 지역 날씨 리스트 `UITableViewCell`
final class RegionWeatherCell: UITableViewCell {
    
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
    
    private let locationIndicatorImageView = UIImageView().then {
        $0.image = UIImage(systemName: "location.fill")?.withRenderingMode(.alwaysTemplate)
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .label
    }
    
    private let addressLabel = UILabel().then {
        $0.text = "Toronto, Canada"
        $0.textColor = .label
        $0.font = .systemFont(ofSize: 17)
    }
    
    private let locationIndicatorAddressStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 5
    }
    
    private let tempLocationStackView = UIStackView().then {
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
        $0.text = "업데이트 5. 27. 오후 12:11"
        $0.textColor = .secondaryLabel
        $0.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
    }
    
    private let weatherLastUpdateStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .trailing
        $0.spacing = 2
    }
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
        self.backgroundView?.frame = self.contentView.frame
        setGradient()
    }
    
    // MARK: - Methods
    
    func configure(model: CurrentWeather) {
        currTempLabel.text = "\(model.temperature)°"
        highTempLabel.text = "H: \(model.maxTemp)°"
        lowTempLabel.text = "L: \(model.minTemp)°"
        locationIndicatorImageView.isHidden = !model.isCurrLocation
        addressLabel.text = model.address
        // TODO: 애니메이션 싱크?
        riveViewModel = RiveViewModel(fileName: model.rive)
        riveViewModel.setView(riveView)
        weatherLabel.text = model.skyInfo
        let date = Date(timeIntervalSince1970: TimeInterval(model.currentTime))
        let customFormat = Date.FormatStyle()
            .month(.defaultDigits)
            .day(.twoDigits)
            .hour(.defaultDigits(amPM: .abbreviated))
            .minute(.defaultDigits)
            .locale(Locale(identifier: "ko_KR"))
        lastUpdateLabel.text = "업데이트 \(date.formatted(customFormat))"
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
                                     tempLocationStackView, weatherLastUpdateStackView)
        
        tempLocationStackView.addArrangedSubviews(highLowTempStackView,
                                                  locationIndicatorAddressStackView)
        
        highLowTempStackView.addArrangedSubviews(highTempLabel, lowTempLabel)
        
        locationIndicatorAddressStackView.addArrangedSubviews(locationIndicatorImageView, addressLabel)
        
        weatherLastUpdateStackView.addArrangedSubviews(weatherLabel,
                                                       lastUpdateLabel)
    }
    
    func setConstraints() {
        currTempLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(40)
            $0.leading.equalToSuperview().inset(20)
        }
        
        riveView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(-85)
            $0.trailing.equalToSuperview().inset(-70)
            $0.width.height.equalTo(320)
        }
        
        tempLocationStackView.snp.makeConstraints {
            $0.leading.equalTo(currTempLabel)
            $0.trailing.equalTo(weatherLastUpdateStackView.snp.leading)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        highLowTempStackView.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        
        locationIndicatorImageView.snp.makeConstraints {
            $0.width.height.equalTo(15)
        }
        
        weatherLastUpdateStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(tempLocationStackView)
            $0.width.equalTo(130)
        }
    }
    
    func setGradient() {
        self.backgroundView = RoundedTrapezoidView(frame: self.bounds)
        
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
