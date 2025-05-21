//
//  WeatherDTO.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/20/25.
//

import Foundation
/// OpenWeatherMap One Call API 응답 데이터를 매핑하는 모델입니다.
///
/// 위도, 경도, 현재 날씨, 시간대, 분 단위 강수량, 시간별 및 일별 예보 데이터를 포함합니다.
struct WeatherResponse: Decodable {
    let lat: Double // 위도
    let lon: Double // 경도
    let timeZone: String // 요청된 시간대 이름
    let timeZoneOffset: Int // UTC에서 초 단위 변화 (Unix)
    let currentWeather: Weather? // 현재 날씨 장보
    let minutelyRains: [MinuteRains] // 분당 강수량 예보
    let hourlyWeathers: [Weather] // 시간별 날씨 예보
    let dailyWeathers: [Weather] // 일별 날씨 예보
    
    /// 분 단위 강수량 정보를 나타내는 구조체
    struct MinuteRains: Decodable {
        let currentTime: Int
        let rainAmount: Double
        
        enum CodingKeys: String, CodingKey {
            case currentTime = "dt"
            case rainAmount = "precipitation"
        }
    }
    
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

struct Weather: Decodable {
    let currentTime: Int // 현재 시간 (Unix)
    let sunriseTime: Int? // 일출 시간 (Unix)
    let sunsetTime: Int? // 일몰 시간 (Unix)
    let moonriseTime: Int? // 달이 뜨는 시간 (Unix)
    let moonsetTime: Int? // 달이 지는 시간 (Unix)
    let moonPhase: Double? // 달의 위상
    let temperature: DoubleOrIntOrObject // 온도
    let tempFeelLike: DoubleOrIntOrObject // 체감온도
    let pressure: Int // 해수면 대기압 hPa
    let humidity: Int // 습도 %
    let clouds: Int // 흐림지수 %
    let uvi: Double // 자외선 지수
    let visibility: Int? // 가시거리 (km)
    let windSpeed: Double? // 미터/초 m/s
    let windDeg: Int? // 풍향 degrees
    let rain: DoubleOrIntOrObject? // 강수량 (1시간단위)
    let snow: DoubleOrIntOrObject? // 강설량 (1시간단위)
    let weatherState: [WeatherState]
    let rainProbability: Double? // 강수확률
    
    struct RainAmount: Decodable {
        let hour: Double // 강수량 (mm/h)
        enum CodingKeys: String, CodingKey {
            case hour = "1h"
        }
    }

    struct SnowAmount: Decodable {
        let hour: Double // 강설량 (mm/h)
        enum CodingKeys: String, CodingKey {
            case hour = "1h"
        }
    }
    
    struct DailyTemperature: Decodable {
        let morning: Double // 아침
        let day: Double // 낮
        let evening: Double // 오후
        let night: Double // 저녁
        let minTemperature: Double // 최저기온
        let maxTemperature: Double // 최고기온
        
        enum CodingKeys: String, CodingKey {
            case day, night
            case morning = "morn"
            case evening = "eve"
            case minTemperature = "min"
            case maxTemperature = "max"
        }
    }

    struct DailyTempFeelLike: Decodable {
        let morning: Double // 아침
        let day: Double // 낮
        let evening: Double // 오후
        let night: Double // 저녁
        
        enum CodingKeys: String, CodingKey {
            case day, night
            case morning = "morn"
            case evening = "eve"
        }
    }
    
    struct WeatherState: Decodable {
        let id: Int // 날씨 상태 ID
        let main: String // 날씨 매개변수 그룹(비,눈 등)
        let icon: String // 날씨 아이콘 ex) https://openweathermap.org/img/wn/(id)@2x.png
    }
    
    /// 타입 검증
    enum DoubleOrIntOrObject: Decodable {
        case int(Int)
        case double(Double)
        case rainAmountObject(RainAmount)
        case snowAmountObject(SnowAmount)
        case dailyTemperature(DailyTemperature)
        case dailyTempFeelLike(DailyTempFeelLike)
        case null
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let value = try? container.decode(Int.self) {
                self = .int(value)
            } else if let value = try? container.decode(Double.self) {
                self = .double(value)
            } else if let value = try? container.decode(RainAmount.self) {
                self = .rainAmountObject(value)
            } else if let value = try? container.decode(SnowAmount.self) {
                self = .snowAmountObject(value)
            } else if let value = try? container.decode(DailyTemperature.self) {
                self = .dailyTemperature(value)
            } else if let value = try? container.decode(DailyTempFeelLike.self) {
                self = .dailyTempFeelLike(value)
            } else {
                self = .null
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case currentTime = "dt"
        case sunriseTime = "sunrise"
        case sunsetTime = "sunset"
        case moonriseTime = "moonrise"
        case moonsetTime = "moonset"
        case moonPhase = "moon_phase"
        case temperature = "temp"
        case tempFeelLike = "feels_like"
        case pressure, humidity, clouds, uvi, rain, snow, visibility
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case weatherState = "weather"
        case rainProbability = "pop"
    }
    
}
