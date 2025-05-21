//
//  HourlyWeatherDTO.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/22/25.
//

import Foundation

/// 시간별 날씨 정보를 담는 데이터 전송 객체 (DTO)입니다.
struct HourlyWeatherDTO: Decodable {
    /// 해당 시간의 유닉스 타임스탬프 (초 단위)
    let currentTime: Int
    /// 해당 시간의 기온 (섭씨)
    let temperature: Double
    /// 해당 시간의 날씨 상태 배열 (예: 맑음, 흐림 등)
    let weatherState: [WeatherStateDTO]
    
    enum CodingKeys: String, CodingKey {
        case currentTime = "dt"
        case temperature = "temp"
        case weatherState = "weather"
    }
}

extension HourlyWeatherDTO {
    func toWeatherImageString() -> String {
        guard let weatherState = self.weatherState.first else {
            print("ERROR:: HourlyWeatherDTO WeatherState is not exist")
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
    
    func toHourlyModel() -> HourlyModel {
        return HourlyModel(hour: self.currentTime.convertUnixTimeToHourString(),
                           temperature: String(self.temperature),
                           weatherInfo: self.toWeatherImageString())
    }
}
