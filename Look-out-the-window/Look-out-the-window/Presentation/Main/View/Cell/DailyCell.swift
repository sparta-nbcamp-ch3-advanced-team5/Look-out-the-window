//
//  DailyCell.swift
//  Look-out-the-window
//
//  Created by GO on 5/21/25.
//

import UIKit
import Then

class DailyCell: UICollectionViewCell {
    static let id = "DailyCell"
    
    private let dayLabel = UILabel().then {
        $0.text = "Now"
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 14)
    }
    
    private let weatherIcon = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.masksToBounds = true
    }
    
    private let lowTempLabel = UILabel().then {
        $0.text = "@'C - Temp"
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 16)
    }
    
    private let highTempLabel = UILabel().then {
        $0.text = "@'C - Temp"
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 16)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(model: DailyModel) {
        dayLabel.text = model.day
        weatherIcon.image = UIImage(named: model.weatherInfo)
        lowTempLabel.text = model.low
        highTempLabel.text = model.high
    }
}

private extension DailyCell {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
//        self.backgroundColor = UIColor(red: 58/255.0, green: 57/255.0, blue: 91/255.0, alpha: 1.0)
        self.backgroundColor = .red
    }
    
    func setViewHierarchy() {
        self.addSubviews(dayLabel, weatherIcon, lowTempLabel, highTempLabel)
    }
    
    func setConstraints() {
        dayLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(safeAreaLayoutGuide).offset(4)
        }
        
        weatherIcon.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(dayLabel.snp.trailing).offset(4)
        }
        
        lowTempLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(weatherIcon.snp.trailing).offset(4)
        }
        
        // TODO: Progress Bar
        
        highTempLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(lowTempLabel.snp.trailing).offset(4)
        }
    }
}
