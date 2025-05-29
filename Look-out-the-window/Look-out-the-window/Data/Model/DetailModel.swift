//
//  DetailModel.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/27/25.
//

import Foundation

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

struct DetailModel {
    let title: DetailType
    let value: String
    let someData: String
}
