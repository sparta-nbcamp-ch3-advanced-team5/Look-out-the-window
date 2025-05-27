//
//  WeatherDataEntity+Mapping.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/27/25.
//

import Foundation

extension WeatherDataEntity {
    func toModel() -> CurrentWeather {
        let hourlyWeatherEntity = sortedHourlyArray
        let hourlyModelList = hourlyWeatherEntity.map { $0.toModel() }
        let dailyWeatherEntity = sortedDailyArray
        let dailyModelList = dailyWeatherEntity.map { $0.toModel() }
        
        return CurrentWeather(address: address ?? "",
                              lat: latitude,
                              lng: longitude,
                              currentTime: Int(currentTime),
                              currentMomentValue: currentMomentValue,
                              sunriseTime: 0,  // TODO: CoreData에 속성 없음
                              sunsetTime: 0,  // TODO: CoreData에 속성 없음
                              temperature: temperature ?? "",
                              maxTemp: maxTemp ?? "",
                              minTemp: minTemp ?? "",
                              tempFeelLike: tempFeelLike ?? "",
                              skyInfo: skyInfo ?? "",
                              pressure: pressure ?? "",
                              humidity: humidity ?? "",
                              clouds: clouds ?? "",
                              uvi: uvi ?? "",
                              visibility: visibility ?? "",
                              windSpeed: windSpeed ?? "",
                              windDeg: windDeg ?? "",
                              rive: rive ?? Rive.sunny,
                              hourlyModel: hourlyModelList,
                              dailyModel: dailyModelList,
                              isCurrLocation: isCurrLocation)
    }
}

extension HourlyWeatherEntity {
    func toModel() -> HourlyModel {
        return HourlyModel(hour: Int(time ?? "") ?? 0,
                           temperature: temperature ?? "",
                           weatherInfo: skyInfo ?? "")
    }
}

extension DailyWeatherEntity {
    func toModel() -> DailyModel {
        return DailyModel(unixTime: Int(currentTime),
                          day: day ?? "",
                          high: maxTemp ?? "",
                          low: minTemp ?? "",
                          weatherInfo: skyInfo ?? "")
    }
}
