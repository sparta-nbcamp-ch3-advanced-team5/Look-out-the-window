//
//  SearchResultCell.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/22/25.
//

import UIKit

import SnapKit
import Then

final class SearchResultCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "SearchResultCell"
    
    // MARK: - UI Components
    
    private let addressLabel = UILabel().then {
        $0.text = "몬트리올, QC 캐나다"
        $0.numberOfLines = 1
    }
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func configure(address: String) {
        addressLabel.text = address
    }
}

// MARK: - UI Methods

private extension SearchResultCell {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.backgroundColor = .clear
    }
    
    func setViewHierarchy() {
        self.contentView.addSubview(addressLabel)
    }
    
    func setConstraints() {
        addressLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
}
