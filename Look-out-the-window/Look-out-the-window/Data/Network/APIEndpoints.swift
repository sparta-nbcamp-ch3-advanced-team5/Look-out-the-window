//
//  APIEndpoints.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/20/25.
//

import Foundation

/// OpenWeatherMap API 등의 엔드포인트를 정의하는 열거형입니다.
///
/// 각 케이스는 고정된 API 엔드포인트 URL을 나타내며, `getURLRequest(_:parameters:)` 메서드를 통해 URLRequest를 생성할 수 있습니다.
enum APIEndpoints: String {
    /// 현재 날씨 및 예보 데이터를 가져오는 OneCall API의 엔드포인트입니다.
    case weather = "https://api.openweathermap.org/data/3.0/onecall"
    
    /// 지정된 엔드포인트와 쿼리 파라미터를 이용해 GET 방식의 `URLRequest`를 생성합니다.
    ///
    /// - Parameters:
    ///   - baseURL: 사용할 API 엔드포인트 (`APIEndpoints`의 케이스).
    ///   - parameters: URL 쿼리로 추가할 파라미터 딕셔너리. 예: `["lat": "37.7749", "lng": "-122.4194", "appid": "..."]`
    /// - Returns: 구성된 `URLRequest` 객체. URL 생성에 실패한 경우 `nil`을 반환합니다.
    ///
    /// - Note: HTTP 메서드는 기본적으로 `"GET"`으로 설정됩니다.
    static func getURLRequest(_ baseURL: Self,
                              parameters: [String: String]) -> URLRequest? {
        guard var urlComponents = URLComponents(string: baseURL.rawValue) else {
            return nil
        }
        var queryItems = [URLQueryItem]()
        for query in parameters {
            queryItems.append(
                URLQueryItem(name: query.key,
                             value: query.value)
            )
        }
        urlComponents.queryItems = queryItems
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
}

/// 날씨 API 요청에 필요한 파라미터를 구성하는 구조체입니다.
///
/// 위도, 경도, API 키, 단위 등의 정보를 포함하며,
/// `makeParameterDict()` 메서드를 통해 URL 쿼리용 딕셔너리로 변환할 수 있습니다.
struct WeatherParameters {
    let lat: Double
    let lng: Double
    let appid: String
    let units = "metric"
    
    /// 날씨 API 파라미터 초기화 메서드
        ///
        /// - Parameters:
        ///   - lat: 위도 값
        ///   - lng: 경도 값
        ///   - appid: OpenWeatherMap에서 발급받은 API 키
    init(lat: Double, lng: Double, appid: String) {
        self.lat = lat
        self.lng = lng
        self.appid = appid
    }
    /// 구조체의 값을 기반으로 URL 쿼리 파라미터 딕셔너리를 생성합니다.
        ///
        /// - Returns: `[String: String]` 형식의 파라미터 딕셔너리
        ///
        /// 예시 출력:
        /// ```swift
        /// [
        ///   "lat": "37.7749",
        ///   "lng": "-122.4194",
        ///   "appid": "your_api_key",
        ///   "units": "metric"
        /// ]
        /// ```
    func makeParameterDict() -> [String: String] {
        var dict = [String: String]()
        dict["lat"] = String(lat)
        dict["lng"] = String(lng)
        dict["appid"] = appid
        dict["units"] = units
        return dict
    }
}

