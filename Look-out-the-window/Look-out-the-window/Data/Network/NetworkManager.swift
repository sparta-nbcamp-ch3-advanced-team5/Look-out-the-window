//
//  NetworkManager.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/20/25.
//

import Foundation
import Alamofire
import RxSwift
/// 네트워크 요청을 처리하는 `NetworkManager` 클래스입니다.
///
/// 이 클래스는 Alamofire와 RxSwift를 활용하여 비동기 네트워크 요청을 수행하며,
/// 응답 데이터를 지정된 `Decodable` 타입으로 디코딩하여 `Single<T>` 형태로 반환합니다.
final class NetworkManager {
    /// 주어진 URLRequest를 통해 네트워크 요청을 수행하고, 응답 데이터를 디코딩합니다.
    ///
    /// 이 메서드는 Alamofire를 사용하여 HTTP 요청을 수행하고,
    /// Swift의 `async/await`를 내부적으로 사용하여 비동기 처리를 수행한 후,
    /// 결과를 `RxSwift.Single`로 래핑하여 반환합니다.
    ///
    /// - Parameter urlRequest: 요청을 보낼 URLRequest 객체입니다.
    /// - Returns: 요청 결과를 담은 `Single<T>` 객체입니다. 성공 시 디코딩된 `T` 타입 객체를 반환하고, 실패 시 에러를 전달합니다.
    ///
    /// - Note: HTTP 상태 코드가 200번대일 때만 성공으로 간주됩니다.
    /// - Warning: 응답 디코딩 실패 시 `DataError.parsingFailed` 에러가 반환됩니다.
    func fetch<T: Decodable>(urlRequest: URLRequest) async -> Single<T> {
        return Single.create { observer in
            Task {
                
                let session = Session.default
                let request = session.request(urlRequest)
                
                guard let url = urlRequest.url else {
                    observer(.failure(NetworkError.invalidURL))
                    return
                }
                let response = await request.serializingDecodable(T.self).response
                
                guard let statusCode = response.response?.statusCode,
                      (200..<300).contains(statusCode) else {
                    observer(.failure(NetworkError.serverError(response.response?.statusCode ?? -1)))
                    return
                }
                
                switch response.result {
                case .success(let data):
                    observer(.success(data))
                case .failure(let error):
                    observer(.failure(DataError.parsingFailed))
                }
                
            }
            return Disposables.create()
        }
    }
}


