//
//  SearchResultViewControllerDelegate.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/23/25.
//

import Foundation

/// `SearchResultViewController` ➡️ `RegionListViewController`
protocol SearchResultViewControllerDelegate: AnyObject {
    func cellDidTapped()
}
