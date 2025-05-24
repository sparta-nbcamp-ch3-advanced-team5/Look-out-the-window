//
//  NSMutableAttributedString+Extension.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/24/25.
//

import UIKit

extension NSMutableAttributedString {
    /// 원하는 `range` 부분만 `color`와 `font`를 지정해줄 수 있는 메서드
    /// - 사용방법
    /// ``` swift
    /// let attributedText = NSMutableAttributedString.makeAttributedString(
    ///     text: text,
    ///     highlightedParts: [
    ///         (range: titleHighlightRange, .label, UIFont.systemFont(ofSize: 17, weight: .bold)),
    ///     ]
    /// )
    /// ```
    /// 지정해주고자 하는 `range`와 `color`, `font`를 지정해주면 됩니다.
    static func makeAttributedString(text: String, highlightedParts: [(range: NSRange, color: UIColor, font: UIFont)]) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        highlightedParts.forEach { part in
            attributedString.addAttribute(.font, value: part.color, range: part.range)
            attributedString.addAttribute(.font, value: part.font, range: part.range)
        }
        return attributedString
    }
}
