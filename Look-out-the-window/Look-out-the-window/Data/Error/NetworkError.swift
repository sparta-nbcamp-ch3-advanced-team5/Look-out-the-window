//
//  NetworkError.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/20/25.
//

import Foundation

/// 네트워크 통신 도중 발생할 수 있는 에러 메세지
enum NetworkError: Error {
    case invalidURL
    case noData
    case requestFailed
    case serverError(Int)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "유효하지 않은 URL"
        case .noData:
            return "데이터 없음"
        case .requestFailed:
            return "요청 실패"
        case .serverError(let code):
            return "서버 에러 \(code)"
        }
    }
}
