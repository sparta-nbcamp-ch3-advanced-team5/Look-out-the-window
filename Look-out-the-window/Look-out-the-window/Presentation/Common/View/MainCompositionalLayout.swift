//
//  MainCompositionalLayout.swift
//  Look-out-the-window
//
//  Created by GO on 5/20/25.
//

import UIKit

enum Section: Int, CaseIterable {
    case hourly   /// 시간별 예보
    case daily    /// 일별 예보
    case detail   /// 상세 정보
}

struct MainCompositionalLayout {
    static func create() -> UICollectionViewCompositionalLayout {
        // Decoration View 등록
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }
            
            switch sectionKind {
            case .hourly:
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(60),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(60 * 5),
                                                       heightDimension: .absolute(80))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 8
                section.orthogonalScrollingBehavior = .continuous
                
                // 기존: leading: 16, trailing: 16
                // 변경: leading: 26, trailing: 26 (10씩 증가)
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 26, bottom: 32, trailing: 26)
                
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(35)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                header.pinToVisibleBounds = false
                header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                
                section.boundarySupplementaryItems = [header]
                
                // ✅ Decoration View 적용
                let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "rounded-background")
                decorationItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20)
                section.decorationItems = [decorationItem]
                
                return section
                
            case .daily:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .absolute(55))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(60))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 0
                // 기존: leading: 16, trailing: 16
                // 변경: leading: 26, trailing: 26 (10씩 증가)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 26, bottom: 0, trailing: 26)
                
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(40)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                header.pinToVisibleBounds = false
                header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                
                section.boundarySupplementaryItems = [header]
                
                // ✅ Decoration View 적용
                let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "rounded-background")
                decorationItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
                section.decorationItems = [decorationItem]
                return section
                
            case .detail:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .fractionalWidth(0.5)
                )
                
                // Left Cell
                let leftItem = NSCollectionLayoutItem(layoutSize: itemSize)
                leftItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)
                
                // Right Cell
                let rightItem = NSCollectionLayoutItem(layoutSize: itemSize)
                rightItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalWidth(0.5)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [leftItem, rightItem]
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 15
                // 기존: leading: 0, trailing: 0
                // 변경: leading: 10, trailing: 10 (10씩 증가)
                section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 20, bottom: 0, trailing: 20)
                
                return section
            }
        }
        
        // Decoration View 등록
        layout.register(RoundedBackgroundView.self,forDecorationViewOfKind: "rounded-background")
        
        return layout
    }
}
