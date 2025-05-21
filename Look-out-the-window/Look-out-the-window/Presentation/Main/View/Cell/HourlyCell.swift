//
//  HourlyCell.swift
//  Look-out-the-window
//
//  Created by GO on 5/21/25.
//

import UIKit

class HourlyCell: UICollectionViewCell {
    static let id = "HourlyCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .brown
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
