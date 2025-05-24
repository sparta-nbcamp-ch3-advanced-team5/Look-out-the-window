//
//  CoreLocationManager.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/21/25.
//

import Foundation
import CoreLocation
import OSLog

import RxRelay

/// `CoreLocation`을 관리하는 싱글톤 매니저
final class CoreLocationManager: NSObject {

    // MARK: - Properties

    private lazy var log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))

    static let shared = CoreLocationManager()

    private let second = UInt64(1_000_000_000)
    private var sleepTask: Task<Void, Error>?

    /// Core Location Manager
    private let locationManager = CLLocationManager()
    /// Geocoder
    private let geocoder = CLGeocoder()
    /// 사용자 국가
    private let locale = Locale(identifier: "Ko-kr")
    
    /// 사용자 현재 위치 정보 `BehaviorRelay`
    let currLocationRelay = BehaviorRelay<LocationModel?>(value: nil)
    
    // MARK: - Initializer

    private override init() {
        locationManager.allowsBackgroundLocationUpdates = true
        super.init()
        locationManager.delegate = self
    }
}

// MARK: - Location Update Methods

extension CoreLocationManager {
    /// 일회성 위치 업데이트 메서드
    func requestLocationOneTime() {
        locationManager.requestLocation()
    }

    /// 1분마다 위치 업데이트를 수행하는 메서드
    func startUpdatingLocationInForeground() {
        os_log(.debug, log: log, #function)
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()

        locationManager.stopMonitoringSignificantLocationChanges()

        sleepTask = Task {
            repeat {
                locationManager.requestLocation()
                try await Task.sleep(nanoseconds: second * 60)
            } while !Task.isCancelled
        }
    }
    
    /// 마지막 위치에서 와이파이, 셀룰러 변경과 같은 상당한 위치 변경이 있을 때 위치를 업데이트하도록 변경하는 메서드
    /// (GPS 사용 X, 대략 500m)
    func startUpdatingLocationInBackground() {
        os_log(.debug, log: log, #function)
        sleepTask?.cancel()
        locationManager.startMonitoringSignificantLocationChanges()
    }
}

// MARK: - Geocoding/Reverse Geocoding Methods

extension CoreLocationManager {
    /// 주어진 주소를 관련된 위치 정보(`LocationModel`)로 변환(Geocoding)하는 비동기 메서드
    ///
    /// - Parameter address: 주소
    /// - Returns: 관련 위치 정보 배열 `[LocationModel]`
    func convertAddressToLocation(of address: String) async -> [LocationModel] {
        do {
            let placemarkList = try await geocoder.geocodeAddressString(address)
            var results = [LocationModel]()
            placemarkList.forEach {
                guard let country = $0.country,
                      let administrativeArea = $0.administrativeArea,
                      let coord = $0.location?.coordinate else { return }
                let locality = $0.locality ?? $0.subLocality ?? $0.thoroughfare ?? ""
                let subLocality = $0.subLocality ?? $0.thoroughfare ?? ""
                
                let location = LocationModel(country: country,
                                             administrativeArea: administrativeArea,
                                             locality: locality,
                                             subLocality: subLocality,
                                             lat: coord.latitude,
                                             lng: coord.longitude)
                
                results.append(location)
                os_log(.debug, log: log, "Geocoding: \(location.toAddress())")
            }
            
            return results
        } catch {
            os_log(.error, log: log, "Geocoding error: \(error.localizedDescription)")
            return []
        }
    }

    /// 사용자 현재 위치 좌표를 위치 정보(`LocationModel`)으로 변환(Reverse Geocoding)하는 비동기 메서드
    ///
    /// - Returns: 변환된 위치 정보 `LocationModel`
    func convertCoordToLocation(lat: CLLocationDegrees, lng: CLLocationDegrees) async -> LocationModel? {
        do {
            let currCoord = CLLocation(latitude: lat, longitude: lng)
            let placemarkList = try await geocoder.reverseGeocodeLocation(currCoord, preferredLocale: locale)
            guard let placemark = placemarkList.last,
                  let country = placemark.country,
                  let administrativeArea = placemark.administrativeArea,
                  let coord = placemark.location?.coordinate else { return nil }
            let locality = placemark.locality ?? placemark.subLocality ?? placemark.thoroughfare ?? ""
            let subLocality = placemark.subLocality ?? placemark.thoroughfare ?? ""
            
            let location = LocationModel(country: country,
                                         administrativeArea: administrativeArea,
                                         locality: locality,
                                         subLocality: subLocality,
                                         lat: coord.latitude,
                                         lng: coord.longitude)
            
            os_log(.debug, log: log, "Reverse Geocoding: \(location.toAddress())")
            return location

        } catch {
            os_log(.error, log: log, "Reverse Geocoding error: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Location Auth Methods

extension CoreLocationManager {
    /// 디바이스 위치 서비스가 활성화 상태인지 확인
    func checkDeviceLocationService() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            os_log(.debug, log: log, "디바이스 위치 서비스: On")
            return true
        } else {
            os_log(.debug, log: log, "디바이스 위치 서비스: Off")
            return false
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension CoreLocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // 앱 위치 접근 권한 확인
        let status = manager.authorizationStatus
        switch status {
        case .authorizedAlways:
            os_log(.debug, log: log, "위치 서비스 권한: 항상 허용됨")
        case .authorizedWhenInUse:
            os_log(.debug, log: log, "위치 서비스 권한: 사용하는 동안 허용됨")
        case .restricted, .denied:
            os_log(.debug, log: log, "위치 서비스 권한: 차단됨")
        case .notDetermined:
            os_log(.debug, log: log, "위치 서비스 권한: 설정 필요")
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        os_log(.debug, log: log, "lat: \(lat), lng: \(lng)")

        Task {
            await currLocationRelay.accept(convertCoordToLocation(lat: lat, lng: lng))
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        os_log(.error, log: log, "CLLocationManager: \(error.localizedDescription)")
    }
}

// 주형: 문자열 안정성 증가
extension Notification.Name {
    static let didUpdateUserLocation = Notification.Name("didUpdateUserLocation")
}
