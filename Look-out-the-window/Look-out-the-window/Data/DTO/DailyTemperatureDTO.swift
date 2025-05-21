//
//  DailyTemperatureDTO.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/22/25.
//

import Foundation

/// 일별 시간대 및 최고/최저 기온 정보를 담는 데이터 전송 객체 (DTO)입니다.
struct DailyTemperatureDTO: Decodable {
    /// 아침 기온 (섭씨)
    let morning: Double
    /// 낮 기온 (섭씨)
    let day: Double
    /// 오후 기온 (섭씨)
    let evening: Double
    /// 저녁 기온 (섭씨)
    let night: Double
    /// 일별 최저 기온 (섭씨)
    let minTemperature: Double
    /// 일별 최고 기온 (섭씨)
    let maxTemperature: Double
    
    enum CodingKeys: String, CodingKey {
        case day, night
        case morning = "morn"
        case evening = "eve"
        case minTemperature = "min"
        case maxTemperature = "max"
    }
}
