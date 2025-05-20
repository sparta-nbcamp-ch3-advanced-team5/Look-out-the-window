//
//  DataError.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/20/25.
//

import Foundation

/// 데이터 처리 도중 발생할 수 있는 에러 메세지
enum DataError: Error {
    case fileNotFound
    case parsingFailed
}

extension DataError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "파일이 존재하지 않음"
        case .parsingFailed:
            return "JSON 파싱 에러"
        }
    }
}
