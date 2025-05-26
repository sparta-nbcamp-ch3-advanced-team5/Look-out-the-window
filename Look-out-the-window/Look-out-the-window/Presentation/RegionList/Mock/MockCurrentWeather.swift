//
//  MockCoord.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/24/25.
//

import Foundation

struct MockCurrentWeather {
    let address: String
    let lat: Double
    let lng: Double
}

let mockCoordList = [
    MockCurrentWeather(address: "경기도 화성시", lat: 37.19681667, lng: 126.8335306),  // 경기도 화성시
//    MockCurrentWeather(address: "경기도 오산시", lat: 37.14691389, lng: 127.0796417),  // 경기도 오산시
//    MockCurrentWeather(address: "경기도 파주시", lat: 37.75708333, lng: 126.7819528),  // 경기도 파주시
//    MockCurrentWeather(address: "서울특별시 종로구", lat: 37.57037778, lng: 126.9816417)  // 서울특별시 종로구
]
