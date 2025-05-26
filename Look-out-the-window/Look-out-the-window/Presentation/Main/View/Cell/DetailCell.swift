//
//  DetailCell.swift
//  Look-out-the-window
//
//  Created by GO on 5/21/25.
//

import UIKit
import SnapKit
import Then

final class DetailCell: UICollectionViewCell {
    static let id = "DetailCell"
    
    let containerView = UIView()
    
    private let cellIcon = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.tintColor = .white
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 16)
    }
    
    private var uvProgressBar: UVProgressBarView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(model: DetailModel) {
        print("DetailCell - bind메서드")
        // 헤더 아이콘, 타이틀 세팅
        let config = UIImage.SymbolConfiguration.preferringMulticolor()
        cellIcon.image = UIImage(systemName: model.title.icon, withConfiguration: config)
        titleLabel.text = model.title.title
        
        // 기존 containerView의 모든 서브뷰 제거
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        switch model.title.viewKind {
        case .uvProgressBar:
            let progressBar = UVProgressBarView()
            if let uvi = Int(model.value) {
                progressBar.updateUI(with: uvi)
            }
            containerView.addSubview(progressBar)
            progressBar.snp.makeConstraints { $0.edges.equalToSuperview() }
            
        case .windView:
            let components = model.value.components(separatedBy: " ")
            let speed = Double(components.first?.replacingOccurrences(of: "m/s", with: "") ?? "0") ?? 0
            let degree = Double(components.last ?? "0") ?? 0
            
            // 여기서 WindView 인스턴스 생성!
            let windView = WindView()
            // radius 60 기준이 140 (cell 너비 - 20) / 2
            windView.bind(degree: degree - 90, speed: speed)
            containerView.addSubview(windView)
            windView.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalTo(windView.snp.width) // 정사각형 보장
            }
            
        case .sunriseSunsetView:
            let sunriseSunsetView = SunriseView()
            // 예시: model.value = "1748204130/1748256182"
            let times = model.value.components(separatedBy: "/")
            let sunrise = Int(times.first ?? "0") ?? 0
            let sunset = Int(times.last ?? "0") ?? 0
            //sunriseSunsetView.bind(sunrise: sunrise, sunset: sunset)
            containerView.addSubview(sunriseSunsetView)
            sunriseSunsetView.snp.makeConstraints { $0.edges.equalToSuperview() }
            
        case .detailCellView:
            let detailView = DetailCellView()
            detailView.bind(model: model)
            containerView.addSubview(detailView)
            detailView.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
    }
    
    private func uvIndexProgress(from value: String) ->CGFloat {
        let uvState: [String: CGFloat] = ["낮음" : 0.2,
                                          "보통" : 0.5,
                                          "높음" : 0.8,
                                          "매우높음" : 1.0]
        if let progress = uvState[value] {
            return progress
        } else if let intValue = Int(value) {
            return min(max(CGFloat(intValue) / 11.0, 0), 1.0)
        } else {
            return 0.0
        }
    }
}

private extension DetailCell {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        contentView.backgroundColor = .systemFill
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
    }
    
    func setViewHierarchy() {
        self.addSubviews(cellIcon, titleLabel, containerView)
    }
    
    func setConstraints() {
        cellIcon.snp.makeConstraints{
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(4)
            $0.size.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints{
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalTo(cellIcon.snp.trailing).offset(4)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(containerView.snp.width)
            $0.bottom.equalToSuperview()
        }
    }
}
