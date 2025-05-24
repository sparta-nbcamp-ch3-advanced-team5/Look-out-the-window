//
//  CurrentWeather+Mapping.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/24/25.
//

import Foundation

extension CurrentWeather {
    func toRegionWeatherModel() -> RegionWeatherModel {
        return RegionWeatherModel(temp: temperature,
                                  maxTemp: maxTemp,
                                  minTemp: minTemp,
                                  location: address ?? "",
                                  rive: rive,
                                  weather: skyInfo)
    }
}
