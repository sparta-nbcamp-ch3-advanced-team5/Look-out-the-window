//
//  MainView.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/20/25.
//

import UIKit

import SnapKit
import Then
import RxDataSources

final class MainView: UIView {
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: MainCompositionalLayout.create())
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MainView {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
        registerCells()
    }
    
    func setAppearance() {
        self.backgroundColor = UIColor(named: "MainBackground")
        collectionView.backgroundColor = UIColor(named: "MainBackground")
    }
    
    func setViewHierarchy() {
        self.addSubviews(collectionView)
    }
    
    func setConstraints() {
        collectionView.snp.makeConstraints{
            $0.top.equalTo(safeAreaLayoutGuide).offset(12)
            $0.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    func registerCells() {
        collectionView.register(HourlyCell.self, forCellWithReuseIdentifier: "HourlyCell")
        collectionView.register(DailyCell.self, forCellWithReuseIdentifier: "DailyCell")
        collectionView.register(DetailCell.self, forCellWithReuseIdentifier: "DetailCell")
        collectionView.register(MainHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: MainHeaderView.id)
    }
}
