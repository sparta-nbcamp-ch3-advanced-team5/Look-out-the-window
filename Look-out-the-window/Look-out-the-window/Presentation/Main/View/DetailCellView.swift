//
//  DetailCellView.swift
//  Look-out-the-window
//
//  Created by GO on 5/25/25.
//

import UIKit
import SnapKit
import Then

final class DetailCellView: UIView {
    
    private let mainValueLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 36, weight: .semibold)
        $0.textColor = .white
    }

    private let subTitleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .white
        $0.text = "in last 24h"
    }

    private let bottomLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .light)
        $0.textColor = .white
        $0.numberOfLines = 0
        $0.text = "Test Test Test Test Test Test Test"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(model: DetailModel) {
        mainValueLabel.text = model.value
    }
}

private extension DetailCellView {
    func setupUI() {
        setAppearance()
        viewHierarchy()
        viewConstraints()
    }
    
    func setAppearance() {
        self.backgroundColor = .mainBackground
    }
    
    func viewHierarchy() {
        self.addSubviews(mainValueLabel, subTitleLabel, bottomLabel)
    }
    
    func viewConstraints() {
        mainValueLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(10)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(mainValueLabel.snp.top).offset(10)
            $0.leading.equalToSuperview().offset(10)
        }
        
        bottomLabel.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.top).offset(10)
            $0.leading.equalToSuperview().offset(10)
        }
    }
}
