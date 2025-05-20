//
//  MainCompositionalLayout.swift
//  Look-out-the-window
//
//  Created by GO on 5/20/25.
//

import UIKit

enum Section: Int, CaseIterable {
    case hourlyForecast /// 시간별 예보
    case dailyForecast /// 일별 예보
    case detailForecast /// 상세 정보
}

struct MainCompositionalLayout {
    static func create() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout {
            section,
            _ in
            switch Section(rawValue: section) {
            case .hourlyForecast:
                
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(80)
                )
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .absolute(80)
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)
                
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(44)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [header]
                
                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 16,
                    bottom: 20,
                    trailing: 16
                )
                return section
                
            case .dailyForecast:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(80)
                )
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(80)
                )
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(44)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [header]
                
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 16,
                    bottom: 20,
                    trailing: 16
                )
                
                return section
                
            case .detailForecast:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(80)
                )
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(80)
                )
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(44)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [header]
                
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 16,
                    bottom: 20,
                    trailing: 16
                )
                
                return section
            
            default:
                return nil
            }
        }
    }
}
