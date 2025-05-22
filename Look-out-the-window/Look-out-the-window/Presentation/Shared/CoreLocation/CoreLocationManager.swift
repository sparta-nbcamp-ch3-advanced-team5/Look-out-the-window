//
//  CoreLocationManager.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/21/25.
//

import Foundation
import CoreLocation
import MapKit
import OSLog

import RxRelay

/// `CoreLocation`의 싱글톤 매니저
final class CoreLocationManager: NSObject {
    
    // MARK: - Properties
    
    private lazy var log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "CoreLocationManager")
    
    static let shared = CoreLocationManager()
    
    /// Core Location Manager
    private let locationManager = CLLocationManager()
    /// Geocoder
    private let geocoder = CLGeocoder()
    /// 사용자 국가
    private let locale = Locale(identifier: "Ko-kr")
    /// 사용자 현재 위치 좌표 (기본값: 광화문 광장)
    var currCoord = CLLocation(latitude: 37.574187, longitude: 126.976882)
    
    // MARK: - Initializer
    
    private override init() {
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 500
        locationManager.allowsBackgroundLocationUpdates = true
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
    
    /// 마지막 위치에서 와이파이, 셀룰러 변경과 같은 상당한 위치 변경이 있을 때(대략 500m) 이동했을 때 위치를 업데이트하도록 변경하는 메서드
    func startUpdatingLocationInBackground() {
        os_log(.debug, log: log, #function)
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
}

// MARK: - Geocoding/Reverse Geocoding Methods

extension CoreLocationManager {
    /// 주소를 좌표로 변환(Geocoding)
    func convertAddressToCoord() {
        
    }
    
    /// 좌표를 주소로 변환(Reverse Geocoding)
    func convertCoordToAddress() async -> [String]? {
        do {
            let placeList = try await geocoder.reverseGeocodeLocation(currCoord, preferredLocale: locale)
            guard let placemark = placeList.last,
                  let administrativeArea = placemark.administrativeArea,
                  let locality = placemark.locality,
                  let subLocality = placemark.subLocality ?? placemark.thoroughfare else { return nil }
            
            let address = [administrativeArea, locality, subLocality]
            print(address)
            return address
        } catch {
            os_log(.error, log: log, "\(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - Private Methods

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
        os_log(.debug, log: log, "lat: \(location.coordinate.latitude), lng: \(location.coordinate.longitude)")
        currCoord = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        os_log(.error, log: log, "\(error.localizedDescription)")
    }
}
