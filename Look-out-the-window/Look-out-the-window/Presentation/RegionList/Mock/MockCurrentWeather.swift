//
//  MockCoord.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/24/25.
//

import Foundation

let mockCurrentWeatherList = [
    CurrentWeather(
        address: "화성시 남양읍",
        lat: 37.1968,
        lng: 126.8335,
        currentTime: 1748284948,
        currentMomentValue: 0.35,
        sunriseTime: 1748290592,
        sunsetTime: 1748342603,
        temperature: "12°C",
        maxTemp: "25°C",
        minTemp: "12°C",
        tempFeelLike: "11°C",
        skyInfo: "흐림",
        pressure: "1018 hPa",
        humidity: "72%",
        clouds: "100%",
        uvi: "0 (낮음)",
        visibility: "10 km",
        windSpeed: "1.8 m/s",
        windDeg: "140°",
        rive: "Cloudy",
        hourlyModel: [
            HourlyModel(hour: 0,  temperature: "13°C", weatherInfo: "cloud.fill"),
            HourlyModel(hour: 3,  temperature: "12°C", weatherInfo: "cloud.fill"),
            HourlyModel(hour: 6,  temperature: "13°C", weatherInfo: "sun.max.fill"),
            HourlyModel(hour: 9,  temperature: "16°C", weatherInfo: "sun.max.fill"),
            HourlyModel(hour: 12, temperature: "20°C", weatherInfo: "sun.max.fill"),
            HourlyModel(hour: 15, temperature: "23°C", weatherInfo: "cloud.sun.fill"),
            HourlyModel(hour: 18, temperature: "19°C", weatherInfo: "cloud.fill"),
            HourlyModel(hour: 21, temperature: "16°C", weatherInfo: "moon.stars.fill")
        ],
        dailyModel: [
            DailyModel(unixTime: 1748314800, day: "화요일", high: "25°C", low: "12°C", weatherInfo: "cloud.fill"),
            DailyModel(unixTime: 1748401200, day: "수요일", high: "21°C", low: "14°C", weatherInfo: "cloud.sun.fill"),
            DailyModel(unixTime: 1748487600, day: "목요일", high: "22°C", low: "16°C", weatherInfo: "sun.max.fill"),
            DailyModel(unixTime: 1748574000, day: "금요일", high: "23°C", low: "17°C", weatherInfo: "sun.max.fill"),
            DailyModel(unixTime: 1748660400, day: "토요일", high: "22°C", low: "16°C", weatherInfo: "cloud.fill")
        ],
        isCurrLocation: false
    ),
    CurrentWeather(
        address: "오산시 원동",
        lat: 37.1469,
        lng: 127.0796,
        currentTime: 1748285300,
        currentMomentValue: 0.35,
        sunriseTime: 1748290541,
        sunsetTime: 1748342536,
        temperature: "13°C",
        maxTemp: "26°C",
        minTemp: "13°C",
        tempFeelLike: "13°C",
        skyInfo: "안개",
        pressure: "1018 hPa",
        humidity: "100%",
        clouds: "0%",
        uvi: "0 (낮음)",
        visibility: "6.4 km",
        windSpeed: "3 m/s",
        windDeg: "90°",
        rive: "Fog",
        hourlyModel: [
            HourlyModel(hour:   0, temperature: "13°C", weatherInfo: "02n"),
            HourlyModel(hour:   3, temperature: "13°C", weatherInfo: "01n"),
            HourlyModel(hour:   6, temperature: "13°C", weatherInfo: "02n"),
            HourlyModel(hour:   9, temperature: "17°C", weatherInfo: "03d"),
            HourlyModel(hour:  12, temperature: "20°C", weatherInfo: "04d"),
            HourlyModel(hour:  15, temperature: "20°C", weatherInfo: "04d"),
            HourlyModel(hour:  18, temperature: "20°C", weatherInfo: "04d"),
            HourlyModel(hour:  21, temperature: "20°C", weatherInfo: "10d")
        ],
        dailyModel: [
            DailyModel(
                unixTime:   1748314800,
                day:        "화요일",
                high:       "26°C",
                low:        "13°C",
                weatherInfo:"cloud.fill"
            ),
            DailyModel(
                unixTime:   1748401200,
                day:        "수요일",
                high:       "27°C",
                low:        "14°C",
                weatherInfo:"cloud.rain.fill"
            ),
            DailyModel(
                unixTime:   1748487600,
                day:        "목요일",
                high:       "27°C",
                low:        "16°C",
                weatherInfo:"sun.max.fill"
            ),
            DailyModel(
                unixTime:   1748574000,
                day:        "금요일",
                high:       "27°C",
                low:        "14°C",
                weatherInfo:"sun.max.fill"
            ),
            DailyModel(
                unixTime:   1748660400,
                day:        "토요일",
                high:       "27°C",
                low:        "16°C",
                weatherInfo:"cloud.fill"
            )
        ],
        isCurrLocation: false
    ),
//    CurrentWeather(
//        address: "파주시 금릉동",
//        lat: 37.7571,
//        lng: 126.7820,
//        currentTime: 1748285464,
//        currentMomentValue: 0.35,
//        sunriseTime: 1748290515,
//        sunsetTime: 1748342705,
//        temperature: "12°C",
//        maxTemp: "26°C",
//        minTemp: "12°C",
//        tempFeelLike: "11°C",
//        skyInfo: "구름",
//        pressure: "1018 hPa",
//        humidity: "70%",
//        clouds: "35%",
//        uvi: "0 (낮음)",
//        visibility: "10 km",
//        windSpeed: "0 m/s",
//        windDeg: "186°",
//        rive: "Clouds",
//        hourlyModel: [
//            HourlyModel(hour:  0, temperature: "13°C", weatherInfo: "03n"),
//            HourlyModel(hour:  3, temperature: "12°C", weatherInfo: "03n"),
//            HourlyModel(hour:  6, temperature: "13°C", weatherInfo: "03n"),
//            HourlyModel(hour:  9, temperature: "14°C", weatherInfo: "03d"),
//            HourlyModel(hour: 12, temperature: "15°C", weatherInfo: "04d"),
//            HourlyModel(hour: 15, temperature: "17°C", weatherInfo: "04d"),
//            HourlyModel(hour: 18, temperature: "20°C", weatherInfo: "04d"),
//            HourlyModel(hour: 21, temperature: "22°C", weatherInfo: "04d")
//        ],
//        dailyModel: [
//            DailyModel(
//                unixTime:   1748314800,
//                day:        "화요일",
//                high:       "26°C",
//                low:        "12°C",
//                weatherInfo:"cloud.fill"
//            ),
//            DailyModel(
//                unixTime:   1748401200,
//                day:        "수요일",
//                high:       "27°C",
//                low:        "16°C",
//                weatherInfo:"cloud.rain.fill"
//            ),
//            DailyModel(
//                unixTime:   1748487600,
//                day:        "목요일",
//                high:       "28°C",
//                low:        "16°C",
//                weatherInfo:"sun.max.fill"
//            ),
//            DailyModel(
//                unixTime:   1748574000,
//                day:        "금요일",
//                high:       "28°C",
//                low:        "16°C",
//                weatherInfo:"sun.max.fill"
//            ),
//            DailyModel(
//                unixTime:   1748660400,
//                day:        "토요일",
//                high:       "29°C",
//                low:        "18°C",
//                weatherInfo:"cloud.fill"
//            )
//        ],
//        isCurrLocation: false
//    ),
//    CurrentWeather(
//        address: "서울특별시 종로1가",
//        lat: 37.5704,
//        lng: 126.9816,
//        currentTime: 1748285565,
//        currentMomentValue: 0.35,
//        sunriseTime: 1748290497,
//        sunsetTime: 1748342627,
//        temperature: "12°C",
//        maxTemp: "26°C",
//        minTemp: "12°C",
//        tempFeelLike: "12°C",
//        skyInfo: "맑음",
//        pressure: "1018 hPa",
//        humidity: "100%",
//        clouds: "0%",
//        uvi: "0 (낮음)",
//        visibility: "6 km",
//        windSpeed: "3 m/s",
//        windDeg: "140°",
//        rive: "Clear",
//        hourlyModel: [
//            HourlyModel(hour: 0, temperature: "13°C", weatherInfo: "02n"),
//            HourlyModel(hour: 3, temperature: "12°C", weatherInfo: "01n"),
//            HourlyModel(hour: 6, temperature: "13°C", weatherInfo: "01n"),
//            HourlyModel(hour: 9, temperature: "14°C", weatherInfo: "03d"),
//            HourlyModel(hour: 12, temperature: "15°C", weatherInfo: "04d"),
//            HourlyModel(hour: 15, temperature: "17°C", weatherInfo: "04d"),
//            HourlyModel(hour: 18, temperature: "20°C", weatherInfo: "04d"),
//            HourlyModel(hour: 21, temperature: "21°C", weatherInfo: "04d")
//        ],
//        dailyModel: [
//            DailyModel(unixTime: 1748314800, day: "화요일", high: "26°C", low: "12°C", weatherInfo: "cloud.fill"),
//            DailyModel(unixTime: 1748401200, day: "수요일", high: "28°C", low: "16°C", weatherInfo: "cloud.rain.fill"),
//            DailyModel(unixTime: 1748487600, day: "목요일", high: "29°C", low: "16°C", weatherInfo: "cloud.rain.fill"),
//            DailyModel(unixTime: 1748574000, day: "금요일", high: "28°C", low: "16°C", weatherInfo: "sun.max.fill"),
//            DailyModel(unixTime: 1748660400, day: "토요일", high: "29°C", low: "17°C", weatherInfo: "cloud.fill")
//        ],
//        isCurrLocation: false
//    )
]
