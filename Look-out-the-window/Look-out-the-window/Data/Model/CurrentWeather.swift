//
//  CurrentWeather.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/22/25.
//

import Foundation

/// 화면에 표시될 현재 날씨 정보를 나타내는 뷰 모델 또는 도메인 모델입니다.
/// API 응답 데이터를 사람이 읽기 쉬운 형식의 문자열로 가공하여 담고 있습니다.
struct CurrentWeather {
    /// 위치 또는 주소 정보 (예: "서울특별시 강남구")
    let address: String?
    /// 현재 시간 Unix
    let currentTime: Int
    /// 현재 순간(새벽, 아침, 낮, 오후, 밤) 기준 투명값 (0.0 ~ 0.5)
    let currentMomentValue: Double
    /// 일출시간
    let sunriseTime: Int
    /// 일몰시간
    let sunsetTime: Int
    /// 현재 기온 (예: "23°C")
    let temperature: String
    /// 최고 기온 (예: "25°C")
    let maxTemp: String
    /// 최저 기온 (예: "17°C")
    let minTemp: String
    /// 체감 온도 (예: "22°C")
    let tempFeelLike: String
    /// 하늘 상태 또는 날씨 요약 (예: "맑음", "비", "흐림")
    let skyInfo: String
    /// 기압 정보 (예: "1013 hPa")
    let pressure: String
    /// 습도 정보 (예: "60%")
    let humidity: String
    /// 구름 양 (예: "30%")
    let clouds: String
    /// 자외선 지수 (예: "5 (보통)")
    let uvi: String
    /// 가시거리 (예: "10 km")
    let visibility: String
    /// 풍속 정보 (예: "3.4 m/s")
    let windSpeed: String
    /// 풍향 정보 (예: "북동풍", "270°")
    let windDeg: String
    /// 일출 또는 일몰 여부 (예: "일출", "일몰") — 상황에 따라 설정됨
    let rive: String
    /// 시간별 날씨 정보 배열
    let hourlyModel: [HourlyModel]
    /// 일별 날씨 정보 배열
    let dailyModel: [DailyModel]
}

// MARK: - 각 섹션 DataModel (수정 필요해 보임)
struct HourlyModel {
  let hour: String   // 포맷 수정 ( 12시간 -> Cell 12개 정도)
  let temperature: String // 섭씨
  // weatherState
  let weatherInfo: String // Asset네이밍 변환받아 전달받을 예정
}

struct DailyModel {
  // 요일, 하늘상태(이미지 -> String), 최저 - 최고 온도
  let day: String
  let high: String
  let low: String
  let weatherInfo: String // Asset네이밍 변환받아 전달받을 예정
}
