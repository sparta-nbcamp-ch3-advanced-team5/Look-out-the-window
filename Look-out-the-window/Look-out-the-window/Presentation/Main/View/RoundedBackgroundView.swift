//
//  RoundedBackgroundView.swift
//  Look-out-the-window
//
//  Created by GO on 5/22/25.
//

import UIKit

final class RoundedBackgroundView: UICollectionReusableView {
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemFill
        layer.cornerRadius = 20
        layer.masksToBounds = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
