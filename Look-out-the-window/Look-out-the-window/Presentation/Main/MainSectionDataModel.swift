//
//  MainSectionDataModel.swift
//  Look-out-the-window
//
//  Created by GO on 5/21/25.
//

import UIKit
import RxDataSources

enum DetailType {
    case sunriseSunset
    case feelsLike
    case humidity
    case uvIndex
    case visibility
    case wind
    case rainSnow
    case clouds

    enum ViewKind {
        case uvProgressBar
        case windView
        case sunriseSunsetView
        case detailCellView
    }

    var viewKind: ViewKind {
        switch self {
        case .uvIndex:         return .uvProgressBar
        case .wind:            return .windView
        case .sunriseSunset:   return .sunriseSunsetView
        default:               return .detailCellView
        }
    }

    var icon: String {
        switch self {
        case .sunriseSunset: return "sun.max"
        case .feelsLike:     return "thermometer.sun.fill"
        case .humidity:      return "humidity.fill"
        case .uvIndex:       return "sun.max"
        case .visibility:    return "eye.fill"
        case .wind:          return "wind"
        case .rainSnow:      return "cloud.rain.fill"
        case .clouds:        return "cloud.fill"
        }
    }

    var title: String {
        switch self {
        case .sunriseSunset: return "일출/일몰"
        case .feelsLike:     return "체감온도"
        case .humidity:      return "습도"
        case .uvIndex:       return "자외선지수"
        case .visibility:    return "가시거리"
        case .wind:          return "풍속/풍향"
        case .rainSnow:      return "강수량/적설량"
        case .clouds:        return "구름량"
        }
    }
}

/// Header
enum SectionHeaderInfo: Int, CaseIterable {
    case hourly
    case daily

    var icon: String {
        switch self {
        case .hourly: return "clock"
        case .daily: return "calendar"
        }
    }

    var title: String {
        switch self {
        case .hourly: return "시간별 예보"
        case .daily: return "일별 예보"
        }
    }
}


// MARK: - 각 섹션 DataModel
struct HourlyModel: Hashable {
    let hour: Int
    let temperature: String
    // weatherState
    let weatherInfo: String // Asset네이밍 변환받아 전달받을 예정
}

struct DailyModel: Hashable {
    // 요일, 하늘상태(이미지 -> String), 최저 - 최고 온도
    let unixTime: Int
    let day: String
    let high: String
    let low: String
    let weatherInfo: String // Asset네이밍 변환받아 전달받을 예정
    let maxTemp: Int
    let minTemp: Int
//    let temperature: String // 현재 온도
}

struct DetailModel {
    let title: DetailType
    let value: String
}

enum MainSectionItem {
    case hourly(HourlyModel)
    case daily(DailyModel)
    case detail(DetailModel)
}

struct MainSection {
    var items: [MainSectionItem]
}

extension MainSection: SectionModelType {
    typealias Item = MainSectionItem

    init(original: MainSection, items: [MainSectionItem]) {
        self = original
        self.items = items
    }
}



