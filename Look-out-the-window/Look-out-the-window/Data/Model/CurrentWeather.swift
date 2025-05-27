//
//  CurrentWeather.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/22/25.
//

import Foundation

import RxDataSources

/// 화면에 표시될 현재 날씨 정보를 나타내는 뷰 모델 또는 도메인 모델입니다.
/// API 응답 데이터를 사람이 읽기 쉬운 형식의 문자열로 가공하여 담고 있습니다.
struct CurrentWeather: Hashable {
    /// 위치 또는 주소 정보 (예: "서울특별시 강남구")
    let address: String
    /// 요청된 위치의 위도
    let lat: Double
    /// 요청된 위치의 경도
    let lng: Double
    /// 현재 시간 Unix
    let currentTime: Int
    /// 현재 순간(새벽, 아침, 낮, 오후, 밤) 기준 투명값 (0.0 ~ 0.5)
    let currentMomentValue: Double
    /// UTC 기준 오프셋 값
    let timeOffset: Int
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
    /// 현재 위치를 나타내는 데이터인지 판별하는 변수
    var isCurrLocation: Bool
    /// 사용자가 CoreData에 저장한 지역인지 판별하는 변수
    var isUserSaved: Bool
    /// 시간당 강수량
    let rainPerHour: Double
    /// 시간당 적설량
    let snowPerHour: Double
}

extension CurrentWeather: IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: String {
        return address
    }
}

extension CurrentWeather {
    func toMainSections() -> [MainSection] {
        let formattedHourlyModels = self.hourlyModel
            .prefix(24) // 앞에서 24개만 사용
            .map { model in
                HourlyModel(
                    hour: model.hour.to24HourInt(),
                    temperature: "\(model.temperature.noDecimalString)°",
                    weatherInfo: model.weatherInfo
                )
            }
        let hourlyItems = formattedHourlyModels.map { MainSectionItem.hourly($0) }
        
        // DailyModel 포맷팅
        let formattedDailyModels = self.dailyModel.map { model in
            DailyModel(
                unixTime: model.unixTime,
                day: String(model.day.prefix(1)),
                high: String(model.high.noDecimalString),
                low: String(model.low.noDecimalString),
                weatherInfo: model.weatherInfo,
                maxTemp: model.maxTemp,
                minTemp: model.minTemp,
                temperature: model.temperature
            )
        }
        
        // dailyItems 생성 (이 값들을 dataSource에도 전달)
        let dailyItems = formattedDailyModels.map { MainSectionItem.daily($0) }

        let detailModels: [DetailModel] = [
            DetailModel(title: .uvIndex, value: self.uvi, someData: ""),
            DetailModel(title: .sunriseSunset, value: "\(self.currentTime)/\(self.sunriseTime)/\(self.sunsetTime)/\(self.timeOffset)", someData: ""),
            DetailModel(title: .wind, value: "\(self.windSpeed)m/s \(self.windDeg)", someData: ""),
            DetailModel(title: .rainSnow, value: "\(self.rainPerHour)mm \n / \(self.snowPerHour)mm", someData: "\(self.rainPerHour)/\(self.snowPerHour)"),
            DetailModel(title: .feelsLike, value: self.tempFeelLike, someData: "\(self.temperature)"),
            DetailModel(title: .humidity, value: self.humidity, someData: ""),
            DetailModel(title: .visibility, value: self.visibility, someData: ""),
            DetailModel(title: .clouds, value: self.clouds, someData: "")
        ]
        
        let detailItems = detailModels.map { MainSectionItem.detail($0) }
        
        return [
            MainSection(items: hourlyItems),
            MainSection(items: dailyItems),
            MainSection(items: detailItems)
        ]
    }
}
