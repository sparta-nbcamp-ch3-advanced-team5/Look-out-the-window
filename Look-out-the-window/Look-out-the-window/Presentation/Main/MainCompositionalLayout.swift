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
                                                       heightDimension: .absolute(60))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 2
                section.orthogonalScrollingBehavior = .continuous

                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 24, trailing: 16)
                
                // ✅ Decoration View 적용
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
                section.interGroupSpacing = 2
                section.contentInsets = NSDirectionalEdgeInsets(top: 46, leading: 16, bottom: 16, trailing: 16)

                // ✅ Decoration View 적용
                let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "rounded-background")
                decorationItem.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0)
                section.decorationItems = [decorationItem]
                return section

            case .detail:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                      heightDimension: .fractionalWidth(0.5))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                item.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(180))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                               repeatingSubitem: item,
                                                               count: 2)

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 32, trailing: 16)

                return section
            }
        }

        layout.register(RoundedBackgroundView.self,
                        forDecorationViewOfKind: "rounded-background")

        return layout
    }
}
