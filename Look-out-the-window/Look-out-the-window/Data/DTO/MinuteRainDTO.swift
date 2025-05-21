//
//  MinuteRainDTO.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/22/25.
//

import Foundation

/// 분 단위 강수량 예보를 나타내는 데이터 전송 객체 (DTO)입니다.
struct MinuteRainDTO: Decodable {
    /// 해당 시간의 유닉스 타임스탬프 (초 단위)
    let currentTime: Int
    /// 1분 간의 예상 강수량 (mm)
    let rainAmount: Double
    
    enum CodingKeys: String, CodingKey {
        case currentTime = "dt"
        case rainAmount = "precipitation"
    }
}
