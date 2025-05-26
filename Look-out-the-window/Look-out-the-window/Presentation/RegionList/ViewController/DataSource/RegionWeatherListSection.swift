//
//  RegionWeatherListSection.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/26/25.
//

import Foundation

import RxDataSources

enum RegionWeatherListSection {
    case currLocation([RegionWeatherListItem])
    case regionList([RegionWeatherListItem])
}

enum RegionWeatherListItem {
    case currLocationWeather(CurrentWeather)
    case regionWeather(CurrentWeather)
}

extension RegionWeatherListSection: SectionModelType {
    typealias Item = RegionWeatherListItem
    
    var items: [RegionWeatherListItem] {
        switch self {
        case .currLocation(let items):
            return items.map { $0 }
        case .regionList(let items):
            return items.map { $0 }
        }
    }
    
    init(original: RegionWeatherListSection, items: [RegionWeatherListItem]) {
        switch original {
        case .currLocation(let items):
            self = .currLocation(items)
        case .regionList(let items):
            self = .regionList(items)
        }
    }
}
