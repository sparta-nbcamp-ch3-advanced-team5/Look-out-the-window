//
//  Double+Extensions.swift
//  Look-out-the-window
//
//  Created by GO on 5/26/25.
//

import Foundation

extension String {
    /// 소수점 이하를 모두 버리고(Int로 내림), String으로 반환
    var noDecimalString: String {
        guard let doubleValue = Double(self) else { return self }
        return String(Int(doubleValue))
    }
    
    /// 소수점 이하를 모두 버리고(Int로 내림), Int로 반환
    var noDecimalInt: Int? {
        guard let doubleValue = Double(self) else { return nil }
        return Int(doubleValue)
    }
}



