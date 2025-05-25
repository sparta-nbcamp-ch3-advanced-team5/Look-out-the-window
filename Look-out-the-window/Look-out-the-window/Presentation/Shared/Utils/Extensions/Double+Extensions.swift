//
//  Double+Extensions.swift
//  Look-out-the-window
//
//  Created by GO on 5/26/25.
//

import Foundation

extension Double {
    
    // 소수점 첫째자리에서 반올림하여 Int로 반환
    var roundedInt: Int {
        return Int(self.rounded())
    }
    
    // 소수점 첫째자리에서 반올림하여 String으로 반환
    var roundedString: String {
        return String(self.roundedInt)
    }
}

