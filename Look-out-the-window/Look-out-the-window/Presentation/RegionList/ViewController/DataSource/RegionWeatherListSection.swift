//
//  RegionWeatherListSection.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/26/25.
//

import Foundation

import RxDataSources

enum RegionWeatherListSectionHeader: String {
    case regionList = "지역 날씨 리스트"
}

struct RegionWeatherListSection {
    let header: RegionWeatherListSectionHeader
    var items: [CurrentWeather]
}

extension RegionWeatherListSection: AnimatableSectionModelType {
    typealias Item = CurrentWeather
    
    var identity: String {
        return header.rawValue
    }
    
    init(original: RegionWeatherListSection, items: [CurrentWeather]) {
        self = original
        self.items = items
    }
}
