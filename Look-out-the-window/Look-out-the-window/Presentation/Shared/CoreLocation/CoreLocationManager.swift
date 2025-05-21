//
//  CoreLocationManager.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/21/25.
//

import Foundation
import CoreLocation
import OSLog

/// `CoreLocation`의 싱글톤 매니저
final class CoreLocationManager: NSObject {
    
    private lazy var log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "CoreLocationManager")
    
    // MARK: - Properties
    
    static let shared = CoreLocationManager()
    private let locationManager: CLLocationManager
    
    private let second: UInt64 = 1_000_000_000
    
    // 백그라운드
    private var timer: Timer?
    
    // MARK: - Initializer
    
    private override init() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 500
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        super.init()
        
        locationManager.delegate = self
    }
}

// MARK: - Location Update Methods

extension CoreLocationManager {
    /// 위치 업데이트를 시작하고, 마지막 위치에서 반경 500m를 벗어났을 때 위치를 업데이트하도록 변경하는 메서드
    func startUpdatingLocationInForeground() {
        os_log(.debug, log: log, #function)
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }
    
    /// 마지막 위치에서 반경 1km를 벗어났을 때 위치를 업데이트하도록 변경하는 메서드
    func startUpdatingLocationInBackground() {
        os_log(.debug, log: log, #function)
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
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
        guard let coord = locations.last?.coordinate else { return }
        os_log(.debug, log: log, "lat: \(coord.latitude), lng: \(coord.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        os_log(.error, log: log, "\(error.localizedDescription)")
    }
}
