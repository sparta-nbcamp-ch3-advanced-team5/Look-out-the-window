//
//  SearchResultView.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/22/25.
//

import UIKit

import SnapKit
import Then

/// 검색 결과 View
final class SearchResultView: UIView {
    
    // MARK: - UI Components
    
    private let searchResultTableView = UITableView(frame: .zero, style: .plain)
    
    // MARK: - Getter
    
    var getTableView: UITableView {
        return searchResultTableView
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

private extension SearchResultView {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.backgroundColor = .clear
        
        searchResultTableView.backgroundColor = .clear
        searchResultTableView.rowHeight = 50
        searchResultTableView.separatorColor = .lightGray
        searchResultTableView.separatorInset.left = 15
        searchResultTableView.separatorInset.right = 15
    }
    
    func setViewHierarchy() {
        self.addSubview(searchResultTableView)
    }
    
    func setConstraints() {
        searchResultTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
