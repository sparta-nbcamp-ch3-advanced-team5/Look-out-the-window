//
//  MidForeEndpoints.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/20/25.
//

import Foundation

/// 중기예보 조회 서비스 Endpoints
///
///- `case midForeDescript`: 중기전망조회
///- `case midLandFore`: 중기육상예보조회
///- `case midTemp`: 중기기온조회
///- `case midSeaFore`: 중기해상예보조회
enum MidForeEndpoints: String {
    case midForeDescript = "/getMidFcst"
    case midLandFore = "/getMidLandFcst"
    case midTemp = "/getMidTa"
    case midSeaFore = "/getMidSeaFcst"
}
