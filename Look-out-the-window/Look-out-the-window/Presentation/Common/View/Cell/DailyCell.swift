//
//  DailyCell.swift
//  Look-out-the-window
//
//  Created by GO on 5/21/25.
//

import UIKit
import Then

final class DailyCell: UICollectionViewCell {
    static let id = "DailyCell"
    
    private let dayLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .monospacedDigitSystemFont(ofSize: 20, weight: .semibold)
        $0.textColor = .white
        $0.textAlignment = .left
    }
    
    private let weatherIcon = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage(systemName: "sun.max")
    }
    
    private let lowTempLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .monospacedDigitSystemFont(ofSize: 20, weight: .semibold)
        $0.textColor = .white
    }
    
    private let highTempLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .monospacedDigitSystemFont(ofSize: 20, weight: .semibold)
        $0.textColor = .white
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.7)
    }
    
    private let progressBar = ProgressBarView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(model: DailyModel, isFirst: Bool, isBottom: Bool) {
        dayLabel.text = isFirst ? "오늘" : model.day
        let config = UIImage.SymbolConfiguration.preferringMulticolor()
        weatherIcon.image = UIImage(systemName: model.weatherInfo, withConfiguration: config)
        lowTempLabel.text = model.low + "°"
        highTempLabel.text = model.high + "°"
        separatorView.isHidden = isBottom
        
        progressBar.updateProgress(
                minTemp: Int(model.low) ?? 0,
                maxTemp: Int(model.high) ?? 0,
                totalMinTemp: model.minTemp,
                totalMaxTemp: model.maxTemp,
                currentTemp: isFirst ? Int(model.temperature) ?? 0 : nil
            )
    }

}

private extension DailyCell {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.backgroundColor = .clear
    }
    
    func setViewHierarchy() {
        self.addSubviews(dayLabel, weatherIcon, lowTempLabel, highTempLabel, separatorView, progressBar)
    }
    
    func setConstraints() {
        dayLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(safeAreaLayoutGuide).offset(12)
            $0.width.equalTo(35)
        }

        weatherIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.size.equalTo(30)
            $0.leading.equalTo(dayLabel.snp.trailing).offset(10)
        }

        lowTempLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(weatherIcon.snp.trailing).offset(8)
        }

        highTempLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(safeAreaLayoutGuide).inset(12)
        }

        progressBar.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.height.equalTo(5)
            $0.leading.equalTo(lowTempLabel.snp.trailing).offset(12)
            $0.trailing.equalTo(highTempLabel.snp.leading).offset(-14)
        }
        
        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview().inset(4)
        }
    }
}
