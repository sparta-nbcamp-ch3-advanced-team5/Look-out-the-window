//
//  CurrentWeatherDTO.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/22/25.
//

import Foundation

/// 현재 날씨 상태를 나타내는 데이터 전송 객체 (DTO)입니다.
struct CurrentWeatherDTO: Decodable {
    /// 현재 시간 (유닉스 타임스탬프, 초 단위)
    let currentTime: Int
    /// 일출 시간 (유닉스 타임스탬프)
    let sunriseTime: Int
    /// 일몰 시간 (유닉스 타임스탬프)
    let sunsetTime: Int
    /// 현재 기온 (섭씨)
    let temperature: Double
    /// 체감 온도 (섭씨)
    let tempFeelLike: Double
    /// 대기압 (hPa, 해수면 기준)
    let pressure: Int
    /// 습도 (%)
    let humidity: Int
    /// 흐림 정도 (%)
    let clouds: Int
    /// 자외선 지수 (UV Index)
    let uvi: Double
    /// 가시거리 (미터 단위)
    let visibility: Int
    /// 풍속 (m/s)
    let windSpeed: Double
    /// 풍향 (0~360도, 북: 0도)
    let windDeg: Int
    /// 최근 강수량 정보 (옵셔널)
    let rain: RainAmountDTO?
    /// 최근 적설량 정보 (옵셔널)
    let snow: SnowAmountDTO?
    /// 날씨 상태 배열 (예: 맑음, 흐림 등)
    let weatherState: [WeatherStateDTO]
    
    enum CodingKeys: String, CodingKey {
        case currentTime = "dt"
        case sunriseTime = "sunrise"
        case sunsetTime = "sunset"
        case temperature = "temp"
        case tempFeelLike = "feels_like"
        case pressure, humidity, clouds, uvi, rain, snow, visibility
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case weatherState = "weather"
    }
}
