//
//  MainHeaderView.swift
//  Look-out-the-window
//
//  Created by GO on 5/22/25.
//

import UIKit
import Then
// TODO: 아이콘, 제목 섹션마다 다르게
final class MainHeaderView: UICollectionReusableView {
    
    static let id = "MainHeaderView"
    
    private let headerIcon = UIImageView().then {
        $0.image = UIImage(systemName: "clock")
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.tintColor = .white
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "시간별 예보"
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 16)
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.7)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(icon: String, title: String) {
        headerIcon.image = UIImage(systemName: icon)
        titleLabel.text = title
    }
}
private extension MainHeaderView {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.backgroundColor = UIColor(red: 58/255.0, green: 57/255.0, blue: 91/255.0, alpha: 1.0)
    }
    
    func setViewHierarchy() {
        self.addSubviews(headerIcon, titleLabel, separatorView)
    }
    
    func setConstraints() {
        headerIcon.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.size.equalTo(16)
            $0.leading.equalTo(safeAreaLayoutGuide).offset(12)
        }
        
        titleLabel.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(headerIcon.snp.trailing).offset(8)
        }
        
        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview().inset(4)
        }
    }
}
