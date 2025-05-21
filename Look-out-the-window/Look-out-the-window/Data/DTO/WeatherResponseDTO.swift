//
//  WeatherResponseDTO.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/20/25.
//

import Foundation

/// 날씨 API로부터 받아오는 전체 날씨 응답을 나타내는 데이터 전송 객체 (DTO)입니다.
/// 위치 정보, 시간대, 현재 날씨, 분 단위/시간별/일별 예보를 포함합니다.
struct WeatherResponseDTO: Decodable {
    /// 요청된 위치의 위도
    let lat: Double
    /// 요청된 위치의 경도
    let lon: Double
    /// 요청된 위치의 시간대 이름 (예: "Asia/Seoul")
    let timeZone: String
    /// UTC와의 시차 (초 단위, 예: +9시간 → 32400)
    let timeZoneOffset: Int
    /// 현재 날씨 정보
    let currentWeather: CurrentWeatherDTO
    /// 분 단위 강수량 예보 배열
    let minutelyRains: [MinuteRainDTO]
    /// 시간별 날씨 예보 배열
    let hourlyWeathers: [HourlyWeatherDTO]
    /// 일별 날씨 예보 배열
    let dailyWeathers: [DailyWeatherDTO]
    
    enum CodingKeys: String, CodingKey {
        case lat, lon
        case timeZone = "timezone"
        case timeZoneOffset = "timezone_offset"
        case currentWeather = "current"
        case hourlyWeathers = "hourly"
        case dailyWeathers = "daily"
        case minutelyRains = "minutely"
    }
}

extension WeatherResponseDTO {
    func toSkyInfoString() -> String {
        guard let weatherState = self.currentWeather.weatherState.first else {
            print("ERROR:: DailyWeatherDTO WeatherState is not exist")
            return ""
        }
        let id = weatherState.id
        var str = "구름"
        if (200..<300).contains(id) {
            str = "천둥"
        } else if (300..<322).contains(id) {
            str = "이슬비"
        } else if (500..<532).contains(id) {
            str = "비"
        } else if (600..<622).contains(id) {
            str = "눈"
        } else if (700..<800).contains(id) {
            str = "안개"
        } else if id == 800 {
            str = "맑음"
        }
        
        return str
    }
    
    func toCurrentWeather() -> CurrentWeather {
        return CurrentWeather(
            address: nil,
            temperature: String(Int(self.currentWeather.temperature)),
            maxTemp: String(Int(self.dailyWeathers[0].temperature.maxTemperature)),
            minTemp: String(Int(self.dailyWeathers[0].temperature.minTemperature)),
            tempFeelLike: String(Int(self.currentWeather.tempFeelLike)),
            skyInfo: self.toSkyInfoString(),
            pressure: String(self.currentWeather.pressure),
            humidity: String(self.currentWeather.humidity),
            clouds: String(self.currentWeather.clouds),
            uvi: String(Int(self.currentWeather.uvi)),
            visibility: String(self.currentWeather.visibility),
            windSpeed: String(Int(self.currentWeather.windSpeed)),
            windDeg: String(self.currentWeather.windDeg),
            rive: nil,
            riveTime: nil,
            hourlyModel: self.hourlyWeathers.map{ $0.toHourlyModel() },
            dailyModel: self.dailyWeathers.map{ $0.toDailyModel() }
        )
    }
}

struct HourlyModel {
    let hour: String      // 포맷 수정  ( 12시간 -> Cell 12개 정도)
    let temperature: String  // 섭씨
    let weatherInfo: String // Asset네이밍 변환받아 전달받을 예정
}

struct DailyModel {
    // 요일, 하늘상태(이미지 -> String), 최저 - 최고 온도
    let day: String
    let high: String
    let low: String
    let weatherInfo: String // Asset네이밍 변환받아 전달받을 예정
}

struct DetailModel {
    // Cell에 UIView 각각 배치 예정
    let title: String
    let value: String
    // TODO: 이미지..
    
}
