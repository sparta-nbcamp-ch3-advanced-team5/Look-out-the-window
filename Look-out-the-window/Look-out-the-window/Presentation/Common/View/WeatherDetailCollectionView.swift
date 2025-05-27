//
//  WeatherDetailCollectionView.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/27/25.
//

import UIKit

import RxDataSources
import RxSwift

final class WeatherDetailCollectionView: UICollectionView {
    
    private let disposeBag = DisposeBag()
    
    lazy var detailDataSource = RxCollectionViewSectionedReloadDataSource<MainSection>(
        configureCell: { dataSource, collectionView, indexPath, item in
            switch item {
            case .hourly(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath) as! HourlyCell
                cell.bind(model: model, isFirst: indexPath.item == 0)
                return cell
            case .daily(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyCell", for: indexPath) as! DailyCell
                let isLast = indexPath.item == (collectionView.numberOfItems(inSection: indexPath.section) - 1)
                cell.bind(model: model, isFirst: indexPath.item == 0, isBottom: isLast)
                return cell
            case .detail(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCell", for: indexPath) as! DetailCell
                cell.bind(model: model)
                return cell
            }
        },
        configureSupplementaryView: { dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
            if indexPath.section == 0 {
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: MainHeaderView.id,
                    for: indexPath
                )
                return header
            } else if indexPath.section == 1 {
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: MainHeaderView.id,
                    for: indexPath
                )
                return header
            }
            return UICollectionReusableView()
        }
    )
    
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: MainCompositionalLayout.create())
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension WeatherDetailCollectionView {
    func setupUI() {
        setAppearance()
        registerCells()
    }
    
    func setAppearance() {
        self.backgroundColor = .mainBackground
    }
    
    func registerCells() {
        self.register(HourlyCell.self, forCellWithReuseIdentifier: "HourlyCell")
        self.register(DailyCell.self, forCellWithReuseIdentifier: "DailyCell")
        self.register(DetailCell.self, forCellWithReuseIdentifier: "DetailCell")
        self.register(MainHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: MainHeaderView.id)
    }
}
