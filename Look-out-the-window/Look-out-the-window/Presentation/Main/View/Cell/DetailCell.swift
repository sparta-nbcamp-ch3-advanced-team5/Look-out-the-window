//
//  DetailCell.swift
//  Look-out-the-window
//
//  Created by GO on 5/21/25.
//

import UIKit
import SnapKit
import Then

// TODO: - Default Custom View로 최대한 재사용 고려

final class DetailCell: UICollectionViewCell {
    static let id = "DetailCell"
    
    let containerView = UIView()
    
    private let cellIcon = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.tintColor = .white
        $0.image = UIImage(systemName: "sun.max")
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "시간별 예보"
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 16)
    }
    
    private var uvProgressBar: UVProgressBarView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
//        containerView.backgroundColor = .blue // test
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(model: DetailModel) {
        cellIcon.image = UIImage(systemName: model.weatherInfo)
        titleLabel.text = model.title
        
        uvProgressBar?.removeFromSuperview()
        uvProgressBar = nil
        
        if model.title == "자외선지수" {
            let progressBar = UVProgressBarView()
            containerView.addSubview(progressBar)
            self.uvProgressBar = progressBar
            
            progressBar.snp.makeConstraints {
                $0.directionalHorizontalEdges.equalToSuperview().inset(8)
                $0.centerY.equalToSuperview()
                $0.height.equalTo(6)
            }
            progressBar.progress = uvIndexProgress(from: model.value)
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
        contentView.backgroundColor = UIColor(red: 58/255.0, green: 57/255.0, blue: 91/255.0, alpha: 1.0)
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
    }
    
    func setViewHierarchy() {
        self.addSubviews(cellIcon, titleLabel, containerView)
    }
    
    func setConstraints() {
        cellIcon.snp.makeConstraints{
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalToSuperview().offset(4)
            $0.size.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints{
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalTo(cellIcon.snp.trailing).offset(4)
        }
        
        containerView.snp.makeConstraints{
            $0.top.equalTo(cellIcon.snp.bottom).offset(4)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(10) //범위 확인용 inset 10
//            $0.size.equalTo(100)
//            $0.center.equalToSuperview()
        }
    }
}
