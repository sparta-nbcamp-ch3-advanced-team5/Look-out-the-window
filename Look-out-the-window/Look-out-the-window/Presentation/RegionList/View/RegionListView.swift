//
//  RegionListView.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/21/25.
//

import UIKit

import SnapKit
import Then

final class RegionListView: UIView {
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension RegionListView {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        
    }
    
    func setViewHierarchy() {
        
    }
    
    func setConstraints() {

    }
}
