//
//  WeatherStateDTO.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/22/25.
//

import Foundation

/// 날씨 상태에 대한 정보를 나타내는 데이터 전송 객체 (DTO)입니다.
struct WeatherStateDTO: Decodable {
    /// 날씨 상태 코드 (예: 500 = 비, 800 = 맑음 등)
    let id: Int
    /// 날씨 그룹명 (예: "Rain", "Snow", "Clear" 등)
    let main: String
    /// 날씨 아이콘 ID (이미지 URL: https://openweathermap.org/img/wn/{icon}@2x.png)
    let icon: String
}
