//
//  RequestAuthManager.swift
//  Look-out-the-window
//
//  Created by 윤주형 on 5/20/25.
//

import CoreLocation
import UIKit

class RequestAuthManager: NSObject, CLLocationManagerDelegate {

    private weak var viewController: UIViewController?
    let locationManager = CLLocationManager()

    init(viewController: UIViewController) {
            super.init()
            self.viewController = viewController
            locationManager.delegate = self
        }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:  // Location services are available.
            print("위치 권한 허용")
//            UserDefaults.standard.set(true, forKey: "isFirstLaunch")

            //실패해도 user가 검색을 통해 수동으로 위치를 찾을 수 있음
        case .restricted, .denied:  // Location services currently unavailable.
            print("위치 권한 거절")

        case .notDetermined:        // Authorization not determined yet.
            manager.requestWhenInUseAuthorization()
            print("!23")
            break

        default:
            break
        }
    }

    //CLLocationManager().requestWhenInUseAuthorization() 를 호출하면
    //   iOS가 시스템 권한 팝업은 자동으로 띄웁니다 (최초 요청 시 한 번만).
    func showRequestLocationNotice() {
        UserDefaults.standard.set(false, forKey: "isFirstLaunch")
        let isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")

        if !isFirstLaunch {
            let alertController = UIAlertController(
                title: "접근 권한 안내",
                message: "----",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                self.locationManager.requestWhenInUseAuthorization()

            }))
            viewController?.present(alertController, animated: true)
        }
    }
}


