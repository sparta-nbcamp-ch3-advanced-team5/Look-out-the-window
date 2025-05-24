//
//  RegionWeatherListView.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/21/25.
//

import UIKit

import SnapKit
import Then

/// 지역 리스트 View
final class RegionWeatherListView: UIView {
    
    // MARK: - UI Components
    
    private let regionListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        $0.collectionViewLayout = layout
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
    }
    
    // MARK: - Getter
    
    var getCollectionView: UICollectionView {
        return regionListCollectionView
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Methods

private extension RegionWeatherListView {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubview(regionListCollectionView)
    }
    
    func setConstraints() {
        regionListCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
