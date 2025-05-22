//
//  RegionListView.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/21/25.
//

import UIKit

import SnapKit
import Then

/// 지역 리스트 View
final class RegionListView: UIView {
    
    // MARK: - UI Components
    
    private let regionListTableView = UITableView()
    
    // MARK: - Getter
    
    var getTableView: UITableView {
        return regionListTableView
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

private extension RegionListView {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.backgroundColor = .clear
        
        regionListTableView.backgroundColor = .clear
        regionListTableView.rowHeight = 200
        regionListTableView.separatorStyle = .none
    }
    
    func setViewHierarchy() {
        self.addSubview(regionListTableView)
    }
    
    func setConstraints() {
        regionListTableView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
    }
}
