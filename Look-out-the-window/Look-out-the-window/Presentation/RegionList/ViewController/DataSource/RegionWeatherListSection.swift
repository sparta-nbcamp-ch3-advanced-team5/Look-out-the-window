//
//  RegionWeatherListSection.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/26/25.
//

import Foundation

import RxDataSources

struct RegionWeatherListSection {
    var items: [CurrentWeather]
}

extension RegionWeatherListSection: SectionModelType {
    typealias Item = CurrentWeather
    
    init(original: RegionWeatherListSection, items: [CurrentWeather]) {
        self = original
        self.items = items
    }
}
