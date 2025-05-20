//
//  ShortForeEndpoints.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/20/25.
//

import Foundation

/// 단기예보 조회 서비스 Endpoints
///
///- `case ultraShortNow`: 초단기실황조회
///- `case ultraShortFore`: 초단기예보조회
///- `case shortFore`: 단기예보조회
///- `case foreVersion`: 예보버전조회
enum ShortForeEndpoints: String {
    case ultraShortNow = "/getUltraSrtNcst"
    case ultraShortFore = "/getUltraSrtFcst"
    case shortFore = "/getVilage"
    case foreVersion = "/getFcstVersion"
}
