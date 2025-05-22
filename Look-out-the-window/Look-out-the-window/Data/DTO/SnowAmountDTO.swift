//
//  SnowAmountDTO.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/22/25.
//

import Foundation

/// 최근 1시간 동안의 강설량 정보를 나타내는 데이터 전송 객체 (DTO)입니다.
struct SnowAmountDTO: Decodable {
    /// 1시간 동안의 강설량 (mm/h)
    let hour: Double
    
    enum CodingKeys: String, CodingKey {
        case hour = "1h"
    }
}
