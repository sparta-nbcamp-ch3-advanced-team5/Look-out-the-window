//
//  RegionWeatherListView.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/21/25.
//

import UIKit

import SnapKit
import Then

/// 지역 리스트 View
final class RegionWeatherListView: UIView {
    
    // MARK: - UI Components
    
    private lazy var regionListTableView = UITableView(frame: .zero, style: .insetGrouped).then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
    }
    // TODO: 토스트 메세지
    
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

private extension RegionWeatherListView {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        self.addSubview(regionListTableView)
    }
    
    func setConstraints() {
        regionListTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
