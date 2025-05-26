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
    let lng: Double
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
        case lat
        case lng = "lon"
        case timeZone = "timezone"
        case timeZoneOffset = "timezone_offset"
        case currentWeather = "current"
        case hourlyWeathers = "hourly"
        case dailyWeathers = "daily"
        case minutelyRains = "minutely"
    }
}

extension WeatherResponseDTO {
    /// 현재 날씨 상태 코드를 기반으로 하늘 상태를 설명하는 한글 문자열을 반환합니다.
    ///
    /// 이 함수는 `currentWeather.weatherState` 배열의 첫 번째 날씨 상태 코드(`id`)를 판별하여
    /// 사람이 이해할 수 있는 한글 표현으로 하늘 상태(기상 상태)를 설명하는 문자열을 반환합니다.
    ///
    /// - 반환값:
    ///   - 날씨 상태에 해당하는 하늘 상태 설명 문자열을 반환합니다.
    ///   - 예: `"맑음"`, `"비"`, `"눈"`, `"천둥"` 등
    ///   - `weatherState`가 비어 있을 경우, 오류 로그를 출력하고 빈 문자열을 반환합니다.
    ///
    /// - 매핑 기준:
    ///   - `200~299`: 천둥번개 → `"천둥"`
    ///   - `300~321`: 이슬비 → `"이슬비"`
    ///   - `500~531`: 비 → `"비"`
    ///   - `600~621`: 눈 → `"눈"`
    ///   - `700~799`: 안개/연무 등 → `"안개"`
    ///   - `800`: 맑음 → `"맑음"`
    ///   - 그 외 또는 명시되지 않은 코드: 기본값 `"구름"`
    ///
    /// - 주의사항:
    ///   - `weatherState` 배열이 비어 있을 경우 `"currentWeather WeatherState is not exist"` 로그를 출력하고 빈 문자열을 반환합니다.
    func toSkyInfoString() -> String {
        guard let weatherState = self.currentWeather.weatherState.first else {
            print("ERROR:: currentWeather WeatherState is not exist")
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
    
    /// 현재 날씨 상태 코드를 기반으로 Rive 애니메이션 리소스에 해당하는 문자열을 반환합니다.
    ///
    /// 이 함수는 `currentWeather.weatherState`의 첫 번째 날씨 상태 코드를 참조하여
    /// 그에 대응되는 Rive 애니메이션 이름(`Rive` 열거형 또는 상수)을 반환합니다.
    /// 반환된 문자열은 Rive 애니메이션 뷰를 로드할 때 사용됩니다.
    ///
    /// - 반환값:
    ///   - 날씨 상태에 해당하는 Rive 애니메이션 리소스 이름을 문자열로 반환합니다.
    ///   - 예: `Rive.sunny`, `Rive.rainy`, `Rive.thunder` 등
    ///   - `weatherState`가 비어 있을 경우, 오류 로그를 출력하고 빈 문자열을 반환합니다.
    ///
    /// - 매핑 기준:
    ///   - `200~299`: 천둥번개 → `Rive.thunder`
    ///   - `300~321`: 이슬비 → `Rive.rainy`
    ///   - `500~531`: 비 → `Rive.rainy`
    ///   - `600~621`: 눈 → `Rive.snow`
    ///   - `700~799`: 안개/먼지 등 → `Rive.fog`
    ///   - `800`: 맑음 → `Rive.sunny`
    ///   - `801`: 약간 흐림 → `Rive.partlyCloudy`
    ///   - 그 외 또는 명시되지 않은 코드: 기본값 `Rive.cloudy`
    ///
    /// - 주의사항:
    ///   - `weatherState` 배열이 비어 있을 경우 `"currentWeather WeatherState is not exist"` 로그를 출력하고 빈 문자열을 반환합니다.
    func toRiveString() -> String {
        guard let weatherState = self.currentWeather.weatherState.first else {
            print("ERROR:: currentWeather WeatherState is not exist")
            return ""
        }
        let id = weatherState.id
        var str = Rive.cloudy
        if (200..<300).contains(id) {
            str = Rive.thunder
        } else if (300..<322).contains(id) {
            str = Rive.rainy
        } else if (500..<532).contains(id) {
            str = Rive.rainy
        } else if (600..<622).contains(id) {
            str = Rive.snow
        } else if (700..<800).contains(id) {
            str = Rive.fog
        } else if id == 800 {
            str = Rive.sunny
        } else if id == 801 {
            str = Rive.partlyCloudy
        }
        
        return str
    }
    
    /// 현재 시간과 타임존 오프셋을 기반으로 하루 중 중심 시점(정오)과의 상대적인 거리값을 계산합니다.
    ///
    /// 이 함수는 하루(24시간)를 기준으로 정오를 중심으로 하여 현재 시간이 정오에서 얼마나 떨어져 있는지를
    /// 0.0에서 0.5 사이의 실수(Double) 값으로 반환합니다.
    ///
    /// - 반환값:
    ///   - 정오(중간 시점)에 가까울수록 0.0에 가까운 값이 반환됩니다.
    ///   - 자정에 가까울수록 0.5에 가까운 값이 반환됩니다.
    ///   - 이 값은 하루의 흐름을 정규화하여 시간 기반 그래픽 표현 등에 활용할 수 있습니다.
    ///
    /// - 내부 동작:
    ///   - `currentTime`에 `timeZoneOffset`을 더하고, 기준 타임존(UTC+9, 즉 32400초)을 보정합니다.
    ///   - 해당 시간의 하루 시작 시점(Unix Range)을 구한 후, 현재 시간에서 하루 시작 시점을 뺀 값을 기준으로 정오와의 상대 위치를 계산합니다.
    ///   - 정오 전/후인지에 따라 계산 방식이 달라지며, 결과는 소수 둘째 자리까지 반올림됩니다.
    ///
    /// - 주의사항:
    ///   - `getUnixRange(unixTime:)`가 실패할 경우, 오류 로그를 출력하고 기본값 `0.0`을 반환합니다.
    func toMomentValue() -> Double {
        let time = self.currentWeather.currentTime + self.timeZoneOffset - 32400
        guard let (startUnix, _) = time.getUnixRange(unixTime: TimeInterval(time)) else {
            print("ERROR \(#function)")
            return 0.0
        }
        var current = TimeInterval(time) - startUnix
        let digit: Double = pow(10, 2)
        let middle = 86400.0 / 2
        
        if current < middle {
            var value = Double(current / middle / 2)
            if value >= 0.5 { value = 0.5 }
            return round((0.5 - value) * digit) / digit
        } else {
            current -= middle
            var value = Double( current / middle / 2)
            if value >= 0.5 { value = 0.5 }
            return round(value * digit) / digit
        }
    }
    
    func toCurrentWeather(address: String? = nil, isCurrLocation: Bool = false) -> CurrentWeather {
        
        let dailyHigh = (dailyWeathers.map { $0.temperature.maxTemperature }).max()
        let dailyMin = (dailyWeathers.map { $0.temperature.minTemperature }).min()
        
        return CurrentWeather(
            address: address,
            lat: lat,
            lng: lng,
            currentTime: self.currentWeather.currentTime + self.timeZoneOffset - 32400,
            currentMomentValue: toMomentValue(),
            sunriseTime: self.currentWeather.sunriseTime + self.timeZoneOffset - 32400,
            sunsetTime: self.currentWeather.sunsetTime + self.timeZoneOffset - 32400,
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
            rive: toRiveString(),
            hourlyModel: self.hourlyWeathers.map{ $0.toHourlyModel() },
            dailyModel: self.dailyWeathers.map{ $0.toDailyModel(maxTemp: dailyHigh, minTemp: dailyMin) },
            isCurrLocation: isCurrLocation
        )
    }
}
