//
//  DailyWeatherDTO.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/22/25.
//

import Foundation

/// 일별 날씨 정보를 담는 데이터 전송 객체 (DTO)입니다.
struct DailyWeatherDTO: Decodable {
    /// 해당 날짜의 유닉스 타임스탬프 (초 단위)
    let currentTime: Int
    /// 해당 날짜의 온도 정보 (최저/최고 등 포함)
    let temperature: DailyTemperatureDTO
    /// 해당 날짜의 날씨 상태 배열 (예: 흐림, 비 등)
    let weatherState: [WeatherStateDTO]
    
    enum CodingKeys: String, CodingKey {
        case currentTime = "dt"
        case temperature = "temp"
        case weatherState = "weather"
    }
}

extension DailyWeatherDTO {
    /// 현재 날씨 상태 코드를 기반으로 해당하는 날씨 이미지 문자열(SF Symbol 이름)을 반환합니다.
    ///
    /// 이 함수는 `weatherState` 배열에서 첫 번째 날씨 상태를 기준으로,
    /// OpenWeatherMap API 등의 날씨 코드(`id`)를 해석하여
    /// 적절한 SF Symbol 이미지 문자열을 결정합니다.
    /// 반환되는 문자열은 SwiftUI 등에서 이미지 표시 시 사용됩니다.
    ///
    /// - 반환값:
    ///   - 날씨 상태에 대응되는 SF Symbol 이미지 이름을 문자열로 반환합니다.
    ///   - 예: "sun.max.fill", "cloud.rain.fill", "cloud.bolt.fill" 등
    ///   - `weatherState`가 비어 있을 경우, 오류 로그를 출력하고 빈 문자열("")을 반환합니다.
    ///
    /// - 매핑 기준:
    ///   - 200~299: 천둥번개
    ///     - 200~202, 230~232: "cloud.bolt.rain.fill"
    ///     - 그 외: "cloud.bolt.fill"
    ///   - 300~321: 이슬비 → "cloud.drizzle.fill"
    ///   - 500~531: 비
    ///     - 502~503: "cloud.heavyrain.fill"
    ///     - 그 외: "cloud.rain.fill"
    ///   - 600~621: 눈 → "cloud.snow.fill"
    ///   - 700~799: 안개/연무 등 → "cloud.fog.fill"
    ///   - 800: 맑음 → "sun.max.fill"
    ///   - 위 조건에 해당되지 않는 경우: 기본값 "cloud.fill"
    ///
    /// - 주의사항:
    ///   - `weatherState` 배열이 비어 있는 경우 함수는 빈 문자열을 반환하며, 로그를 출력합니다.
    func toWeatherImageString() -> String {
        guard let weatherState = self.weatherState.first else {
            print("ERROR:: DailyWeatherDTO WeatherState is not exist")
            return ""
        }
        let id = weatherState.id
        var imageString = "cloud.fill"
        if (200..<300).contains(id) {
            if (200...202).contains(id) || (230...232).contains(id) {
                imageString = "cloud.bolt.rain.fill"
            } else {
                imageString = "cloud.bolt.fill"
            }
        } else if (300..<322).contains(id) {
            imageString = "cloud.drizzle.fill"
        } else if (500..<532).contains(id) {
            if (502...503).contains(id) {
                imageString = "cloud.heavyrain.fill"
            } else {
                imageString = "cloud.rain.fill"
            }
        } else if (600..<622).contains(id) {
            imageString = "cloud.snow.fill"
        } else if (700..<800).contains(id) {
            imageString = "cloud.fog.fill"
        } else if id == 800 {
            imageString = "sun.max.fill"
        }
        
        return imageString
    }
    
    func toDailyModel() -> DailyModel {
        return DailyModel(unixTime: self.currentTime,
                          day: self.currentTime.convertUnixTimeToWeekString(),
                          high: String(self.temperature.maxTemperature),
                          low: String(self.temperature.minTemperature),
                          weatherInfo: self.toWeatherImageString())
    }
}
