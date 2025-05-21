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
        $0.font = .boldSystemFont(ofSize: 18)
        $0.textColor = .white
    }
    
    private let weatherIcon = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.image = UIImage(systemName: "sun.max")
        $0.tintColor = .white
    }
    
    private let lowTempLabel = UILabel().then {
        $0.text = "18'C"
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = .white
    }
    
    private let highTempLabel = UILabel().then {
        $0.text = "30'C"
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = .white
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.2)
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
        self.backgroundColor = UIColor(red: 58/255.0, green: 57/255.0, blue: 91/255.0, alpha: 1.0)
    }
    
    func setViewHierarchy() {
        self.addSubviews(dayLabel, weatherIcon, lowTempLabel, highTempLabel, separatorView)
    }
    
    func setConstraints() {
        dayLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(safeAreaLayoutGuide).offset(12)
        }
        
        weatherIcon.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.size.equalTo(30)
            $0.leading.equalTo(dayLabel.snp.trailing).offset(20)
        }
        
        lowTempLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(weatherIcon.snp.trailing).offset(12)
        }
        
        // TODO: Progress Bar
        
        highTempLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(safeAreaLayoutGuide).inset(12)
        }
        
        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().inset(10)
        }
    }
}
