//
//  DailyModel.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/27/25.
//

import Foundation

struct DailyModel: Hashable {
    // 요일, 하늘상태(이미지 -> String), 최저 - 최고 온도
    let unixTime: Int
    let day: String
    let high: String
    let low: String
    let weatherInfo: String // Asset네이밍 변환받아 전달받을 예정
    let maxTemp: Int
    let minTemp: Int
    let temperature: String // 현재 온도
}
