//
//  DailyCell.swift
//  Look-out-the-window
//
//  Created by GO on 5/21/25.
//

import UIKit
import Then

// TODO: - SF Symbol 컬러

final class DailyCell: UICollectionViewCell {
    static let id = "DailyCell"
    
    private let dayLabel = UILabel().then {
        $0.text = "Now"
        $0.textAlignment = .center
        $0.font = .monospacedDigitSystemFont(ofSize: 20, weight: .semibold)
        $0.textColor = .white
    }
    
    private let weatherIcon = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.image = UIImage(systemName: "sun.max")
    }
    
    private let lowTempLabel = UILabel().then {
        $0.text = "18'C"
        $0.textAlignment = .center
        $0.font = .monospacedDigitSystemFont(ofSize: 20, weight: .semibold)
        $0.textColor = .white
    }
    
    private let highTempLabel = UILabel().then {
        $0.text = "30'C"
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
    
    func bind(model: DailyModel, isBottom: Bool, totalMin: Int, totalMax: Int) {
        dayLabel.text = model.day
        let config = UIImage.SymbolConfiguration.preferringMulticolor()
        weatherIcon.image = UIImage(systemName: model.weatherInfo, withConfiguration: config)
        lowTempLabel.text = model.low + "°"
        highTempLabel.text = model.high + "°"
        separatorView.isHidden = isBottom

        let minTemp = Int(model.low)
        let maxTemp = Int(model.high)

        progressBar.minTemp = minTemp ?? 0
        progressBar.maxTemp = maxTemp ?? 0
        progressBar.totalMinTemp = totalMin
        progressBar.totalMaxTemp = totalMax
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
        dayLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(safeAreaLayoutGuide).offset(12)
            // width값 추가
            $0.width.equalTo(35)
        }
        
        weatherIcon.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.size.equalTo(30)
            $0.leading.equalTo(dayLabel.snp.trailing).offset(12)
        }
        
        lowTempLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(weatherIcon.snp.trailing).offset(12)
        }
        
        // TODO: Progress Bar
        progressBar.snp.makeConstraints{
            $0.height.equalTo(5)
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(lowTempLabel.snp.trailing).offset(30)
            $0.trailing.equalTo(highTempLabel.snp.leading).offset(-30)
        }
        
        highTempLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(safeAreaLayoutGuide).inset(12)
        }
        
        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview().inset(4)
        }
    }
}
