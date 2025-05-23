//
//  CoreLocationManager.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/21/25.
//

import Foundation
import CoreLocation
import OSLog

/// `CoreLocation`을 관리하는 싱글톤 매니저
final class CoreLocationManager: NSObject {
    
    // MARK: - Properties
    
    private lazy var log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    static let shared = CoreLocationManager()
    
    /// Core Location Manager
    private let locationManager = CLLocationManager()
    /// Geocoder
    private let geocoder = CLGeocoder()
    /// 사용자 국가
    private let locale = Locale(identifier: "Ko-kr")
    
    /// 사용자 현재 위치 정보 (기본값: 광화문 광장)
    var currLocation: LocationModel
    
    // MARK: - Initializer
    
    private override init() {
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 500
        locationManager.allowsBackgroundLocationUpdates = true
        currLocation = LocationModel()
        super.init()
        locationManager.delegate = self
    }
}

// MARK: - Location Update Methods

extension CoreLocationManager {
    /// 위치 업데이트를 시작하고, 마지막 위치에서 500m 이상 이동했을 때 위치를 업데이트하도록 변경하는 메서드
    func startUpdatingLocationInForeground() {
        os_log(.debug, log: log, #function)
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }
    
    /// 마지막 위치에서 와이파이, 셀룰러 변경과 같은 상당한 위치 변경이 있을 때(GPS 사용 X, 대략 500m) 이동했을 때 위치를 업데이트하도록 변경하는 메서드
    func startUpdatingLocationInBackground() {
        os_log(.debug, log: log, #function)
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
}

// MARK: - Geocoding/Reverse Geocoding Methods

extension CoreLocationManager {
    /// 주어진 검색어와 관련된 위치 정보(`LocationModel`)들을 반환하는 비동기 메서드
    ///
    /// - Parameter address: 검색어(주소)
    /// - Returns: 관련 위치 정보 배열 `[LocationModel]`
    func convertAddressToCoord(of address: String) async -> [LocationModel] {
        do {
            let placemarkList = try await geocoder.geocodeAddressString(address)
            var results = [LocationModel]()
            placemarkList.forEach {
                guard let administrativeArea = $0.administrativeArea,
                      let locality = $0.locality else { return }
                let subLocality = $0.subLocality ?? $0.thoroughfare ?? ""
                let areasOfInterest = $0.areasOfInterest?.first ?? ""
                let coord = $0.location?.coordinate
                
                let location = LocationModel(administrativeArea: administrativeArea,
                                        locality: locality,
                                        subLocality: subLocality,
                                        areasOfInterest: areasOfInterest,
                                        lat: coord?.latitude ?? 37.574187,
                                        lng: coord?.longitude ?? 126.976882)
                
                results.append(location)
            }
            
            os_log(.debug, log: log, "\(results)")
            return results
        } catch {
            os_log(.error, log: log, "Geocoding error: \(error.localizedDescription)")
            return []
        }
    }
    
    /// 사용자 현재 위치 좌표를 위치 정보(`LocationModel`)으로 변환(Reverse Geocoding)하는 비동기 메서드
    ///
    /// - Returns: 변환된 위치 정보 `LocationModel`
    func convertCoordToAddress(lat: CLLocationDegrees, lng: CLLocationDegrees) async -> LocationModel? {
        do {
            let currCoord = CLLocation(latitude: lat, longitude: lng)
            let placemarkList = try await geocoder.reverseGeocodeLocation(currCoord, preferredLocale: locale)
            guard let placemark = placemarkList.last,
                  let administrativeArea = placemark.administrativeArea,
                  let locality = placemark.locality else { return currLocation }
            let subLocality = placemark.subLocality ?? placemark.thoroughfare ?? ""
            let areasOfInterest = placemark.areasOfInterest?.first ?? ""
            let coord = placemark.location?.coordinate
            
            let location = LocationModel(administrativeArea: administrativeArea,
                                         locality: locality,
                                         subLocality: subLocality,
                                         areasOfInterest: areasOfInterest,
                                         lat: coord?.latitude ?? 37.574187,
                                         lng: coord?.longitude ?? 126.976882)
            
            dump(location)
            return location
            
        } catch {
            os_log(.error, log: log, "Reverse Geocoding error: \(error.localizedDescription)")
        }
        return currLocation
    }
}

// MARK: - Location Auth Methods

private extension CoreLocationManager {
    /// 디바이스 위치 서비스가 활성화 상태인지 확인
    func checkDeviceLocationService() {
        Task.detached { [weak self] in
            guard let self else { return }
            if CLLocationManager.locationServicesEnabled() {
                os_log(.debug, log: self.log, "디바이스 위치 서비스: On")
                
                let status = locationManager.authorizationStatus
                checkUserLocationServiceAuthorization(status: status)
            } else {
                os_log(.debug, log: self.log, "디바이스 위치 서비스: Off")
            }
        }
    }
    
    /// 앱 위치 접근 권한 확인
    func checkUserLocationServiceAuthorization(status: CLAuthorizationStatus) {
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedAlways:
            os_log(.debug, log: log, "위치 서비스 권한: 항상 허용됨")
        case .authorizedWhenInUse:
            os_log(.debug, log: log, "위치 서비스 권한: 사용하는 동안 허용됨")
        case .restricted, .denied:
            os_log(.debug, log: log, "위치 서비스 권한: 차단됨")
            // TODO: 허용 Alert?
        case .notDetermined:
            os_log(.debug, log: log, "위치 서비스 권한: 설정 필요")
            // TODO: 허용 Alert?
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension CoreLocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkDeviceLocationService()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        os_log(.debug, log: log, "lat: \(lat), lng: \(lng)")
        
        Task {
            await currLocation = convertCoordToAddress(lat: lat, lng: lng) ?? currLocation
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        os_log(.error, log: log, "CLLocationManager: \(error.localizedDescription)")
    }
}
