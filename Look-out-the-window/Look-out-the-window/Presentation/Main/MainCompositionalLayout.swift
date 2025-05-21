//
//  MainCompositionalLayout.swift
//  Look-out-the-window
//
//  Created by GO on 5/20/25.
//

import UIKit

enum Section: Int, CaseIterable {
    case hourly /// 시간별 예보
    case daily /// 일별 예보
    case detail /// 상세 정보
}

// TODO: - Section간 거리가 좀 멀어보임
// TODO: - 각 Section 코너 둥글게 처리 -> group 단위에서 둥글게 처리하는건 불가능 -> Decoration View 개념이 있음 (iOS 14+)

struct MainCompositionalLayout {
    static func create() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            switch Section(rawValue: sectionIndex) {
            case .hourly:
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(60),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(60 * 5),
                                                       heightDimension: .absolute(60))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                               subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 8
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16)
                
                // Decoration
                let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "rounded-background")
                decorationItem.contentInsets = .zero
                section.decorationItems = [decorationItem]
                
                return section

            case .daily:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .absolute(64))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(64))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 16, bottom: 16, trailing: 16)
                
                // Decoration
                let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "rounded-background")
                decorationItem.contentInsets = .zero
                section.decorationItems = [decorationItem]
                
                return section

            case .detail:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                      heightDimension: .fractionalWidth(0.5)) // 정사각형
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(180))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                               repeatingSubitem: item,
                                                               count: 2)

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 16, bottom: 16, trailing: 16)
                
                // Decoration
                let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "rounded-background")
                decorationItem.contentInsets = .zero
                section.decorationItems = [decorationItem]
                
                return section

            default:
                return nil
            }
        }
        
        layout.register(RoundedBackgroundView.self, forDecorationViewOfKind: "rounded-background")
        return layout
    }
}
