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

struct MainCompositionalLayout {
    static func create() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout {
            section,
            _ in
            switch Section(rawValue: section) {
            case .hourly:
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalWidth(1.0))
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.22),
                                                       heightDimension: .absolute(80))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                               subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .continuous // 가로 스크롤
                section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                                leading: 16,
                                                                bottom: 8,
                                                                trailing: 16)
                return section
                
            case .daily:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalWidth(1.0))
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(64))
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                             subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .absolute(44))
                
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                                leading: 16,
                                                                bottom: 8,
                                                                trailing: 16)
                
                return section
                
            case .detail: // 2열 그리드 형태
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 8,
                                                             leading: 8,
                                                             bottom: 8,
                                                             trailing: 8)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(120))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                               repeatingSubitem: item,
                                                               count: 2)
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 8
                section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                                leading: 16,
                                                                bottom: 8,
                                                                trailing: 16)
                return section
                
            default:
                return nil
            }
        }
    }
}
