//
//  BackgroundView.swift
//  Look-out-the-window
//
//  Created by 정근호 on 5/20/25.
//

import UIKit

import SnapKit
import Then

final class BackgroundView: UIView {
    
    private(set) var setBackgroundColor: UIColor
        
    // MARK: - UI Components
    private lazy var infoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .center
        $0.spacing = 4
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
    init(frame: CGRect, setBackgroundColor: UIColor) {
        self.setBackgroundColor = setBackgroundColor
        super.init(frame: frame)
        self.backgroundColor = setBackgroundColor
        print("배경색: \(self.setBackgroundColor)")
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI & Layout
    private func setupUI() {
        self.addSubviews(infoStackView)
        infoStackView.addArrangedSubviews(city, temperature, weather, tempStackView)
        tempStackView.addArrangedSubviews(highestTemp, lowestTemp)
        
        infoStackView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).inset(50)
            $0.centerX.equalToSuperview()
        }
    }
}
