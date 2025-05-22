//
//  DetailCell.swift
//  Look-out-the-window
//
//  Created by GO on 5/21/25.
//

import UIKit

final class DetailCell: UICollectionViewCell {
    static let id = "DetailCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = UIColor(red: 58/255.0, green: 57/255.0, blue: 91/255.0, alpha: 1.0)
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
