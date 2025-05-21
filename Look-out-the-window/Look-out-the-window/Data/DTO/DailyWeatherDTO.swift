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
        return DailyModel(day: self.currentTime.convertUnixTimeToWeekString(),
                          high: String(self.temperature.maxTemperature),
                          low: String(self.temperature.minTemperature),
                          weatherInfo: self.toWeatherImageString())
    }
}
