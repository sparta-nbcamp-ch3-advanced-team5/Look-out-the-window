//
//  UIStackView+Extension.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/20/25.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach {
            self.addArrangedSubview($0)
        }
    }
}
