//
//  LocationModel.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/22/25.
//

import Foundation

/// 위치 정보를 나타내는 Model
///
/// - `administrativeArea`: 광역시/도
/// - `locality`: 시/군/구
/// - `subLocality`: 읍/면/동(없으면 빈 값)
/// - `areasOfInterest`: 장소 이름(없으면 빈 값)
/// - `lat`: 위도(없으면 기본값)
/// - `lng`: 경도(없으면 기본값)
struct LocationModel {
    let administrativeArea: String
    let locality: String
    let subLocality: String
    let areasOfInterest: String
    let lat: Double
    let lng: Double
}
