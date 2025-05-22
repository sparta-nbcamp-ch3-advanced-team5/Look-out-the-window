//
//  SunriseView.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/23/25.
//

import UIKit
import SnapKit

final class SunriseView: UIView {
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "6:23"
        label.textColor = .white
        label.font = .systemFont(ofSize: 32, weight: .regular)
        return label
    }()
    
    private let timeMarkLabel: UILabel = {
        let label = UILabel()
        label.text = "AM"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBlue
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SunriseView {
    func setupUI() {
        self.addSubviews(timeLabel, timeMarkLabel)
        configureLayout()
    }
    
    func configureLayout() {
        timeLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(5)
        }
        timeMarkLabel.snp.makeConstraints {
            $0.leading.equalTo(timeLabel.snp.trailing)
            $0.top.equalToSuperview().inset(16)
        }
    }
    
}
