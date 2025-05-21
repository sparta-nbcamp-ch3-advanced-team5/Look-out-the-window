//
//  HourlyCell.swift
//  Look-out-the-window
//
//  Created by GO on 5/21/25.
//

import UIKit

class HourlyCell: UICollectionViewCell {
    static let id = "HourlyCell"
    
    private let hourLabel = UILabel().then {
        $0.text = "9PM"
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: 16)
    }
    
    private let weatherIcon = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.image = UIImage(systemName: "sun.max")
        $0.tintColor = .white
    }
    
    private let tempLabel = UILabel().then {
        $0.text = "18'C"
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: 18)
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
    
    func bind(model: HourlyModel) {
        
    }
}

private extension HourlyCell {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.backgroundColor = UIColor(red: 58/255.0, green: 57/255.0, blue: 91/255.0, alpha: 1.0)
    }
    
    func setViewHierarchy() {
        self.addSubviews(hourLabel, weatherIcon, tempLabel)
    }
    
    func setConstraints() {
        hourLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(4)
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
