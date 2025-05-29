//
//  HourlyModel.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/27/25.
//

import Foundation

struct HourlyModel: Hashable {
    let hour: Int
    let temperature: String
    // weatherState
    let weatherInfo: String // Asset네이밍 변환받아 전달받을 예정
}
