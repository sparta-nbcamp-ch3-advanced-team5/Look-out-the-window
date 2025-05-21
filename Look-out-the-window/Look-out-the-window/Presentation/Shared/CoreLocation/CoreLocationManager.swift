//
//  CoreLocationManager.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/21/25.
//

import Foundation
import CoreLocation

final class CoreLocationManager: NSObject {
    
    static let shared: CoreLocationManager = {
        let instance = CoreLocationManager()
        locationManager.delegate = instance
        
        return instance
    }()
    
    static let locationManager = CLLocationManager()
}

extension CoreLocationManager: CLLocationManagerDelegate {
    
}
