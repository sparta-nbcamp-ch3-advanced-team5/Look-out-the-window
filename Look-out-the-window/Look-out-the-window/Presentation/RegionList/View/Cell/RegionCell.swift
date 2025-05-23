//
//  RegionCell.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/22/25.
//

import UIKit

import SnapKit
import Then

import RiveRuntime

/// 지역 리스트 `UITableViewCell`
final class RegionCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "RegionCell"
    
    private(set) var riveViewModel: RiveViewModel
    
    
    
    // MARK: - UI Components
    
    private lazy var riveView = RiveView()
    
    private let currTempLabel = UILabel().then {
        $0.text = "20°"
        $0.textColor = .label
        $0.font = .monospacedDigitSystemFont(ofSize: 64, weight: .regular)
    }
    
    private let highTempLabel = UILabel().then {
        $0.text = "H: -10°"
        $0.textColor = .secondaryLabel
        $0.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    }
    
    private let lowTempLabel = UILabel().then {
        $0.text = "L: -21°"
        $0.textColor = .secondaryLabel
        $0.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    }
    
    private let highLowTempStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 2
    }
    
    private let locationLabel = UILabel().then {
        $0.text = "Toronto, Canada"
        $0.textColor = .label
        $0.font = .systemFont(ofSize: 17)
    }
    
    private let tempAndLocationStack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 2
    }
    
//    private let weatherImageView = UIImageView().then {
//        $0.image = UIImage(systemName: "cloud.sun.rain.fill", withConfiguration: UIImage.SymbolConfiguration.preferringMulticolor())
//        $0.contentMode = .scaleAspectFit
//    }
    
    private let windLabel = UILabel().then {
        $0.text = "Fast Wind"
        $0.textColor = .label
        $0.font = .systemFont(ofSize: 13)
    }
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        // TODO: - 임시 fileName
        self.riveViewModel = RiveViewModel(fileName: Rive.partlyCloudy)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.riveView = riveViewModel.createRiveView()
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setGradient()
    }
    
    // MARK: - Methods
    
    func configure() {
        
    }
}

// MARK: - UI Methods

private extension RegionCell {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
//        self.layer.masksToBounds = true
        self.riveView.preferredFramesPerSecond = 10
        self.riveView.isUserInteractionEnabled = false
    }
    
    func setViewHierarchy() {
//        self.contentView.addSubviews(currTempLabel, weatherImageView,
//                         tempAndLocationStack, windLabel)
        
        self.contentView.addSubviews(currTempLabel, riveView,
                         tempAndLocationStack, windLabel)
        
        tempAndLocationStack.addArrangedSubviews(highLowTempStackView,
                                                 locationLabel)
        
        highLowTempStackView.addArrangedSubviews(highTempLabel, lowTempLabel)
    }
    
    func setConstraints() {
        currTempLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(40)
            $0.leading.equalToSuperview().inset(20)
        }
        
//        weatherImageView.snp.makeConstraints {
//            $0.top.equalToSuperview().inset(5)
//            $0.trailing.equalToSuperview().inset(20)
//            $0.width.height.equalTo(150)
//        }
        
        riveView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(-85)
            $0.trailing.equalToSuperview().inset(-80)
            $0.width.height.equalTo(350)
        }
        
        tempAndLocationStack.snp.makeConstraints {
            $0.leading.equalTo(currTempLabel)
            $0.bottom.equalToSuperview().inset(20)
            $0.width.greaterThanOrEqualTo(180)
        }
        
        highLowTempStackView.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        
        windLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(tempAndLocationStack)
        }
    }
    
    func setGradient() {
        self.backgroundView = RegionCellBGView(frame: self.frame)
        
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
