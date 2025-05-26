//
//  PushNotificationCenter.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/26/25.
//

import Foundation
import UserNotifications

/// `PushNotificationCenter`는 앱의 푸시 알림 관련 설정 및 로컬 알림 전송 기능을 관리하는 싱글톤 클래스입니다.
final class PushNotificationCenter {
    
    /// `PushNotificationCenter`의 공유 인스턴스입니다. 싱글톤 패턴으로 구현되어 앱 전체에서 하나의 인스턴스만 사용됩니다.
    static let shared = PushNotificationCenter()
    
    /// 외부에서 인스턴스를 생성하지 못하도록 `private` 생성자를 사용합니다.
    private init() { }

    /// 사용자에게 푸시 알림 권한을 요청합니다.
    ///
    /// - 요청하는 권한: 알림, 뱃지, 사운드
    /// - 사용자가 권한 요청에 응답하면 내부적으로 알림 허용 여부가 처리됩니다.
    func setPushNotificationAuthorization() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions
        ) { _, _ in
            // 응답 처리 필요 시 여기에 작성
        }
    }

    /// 매일 오전 7시에 현재 날씨 정보를 포함한 로컬 알림을 전송합니다.
    ///
    /// - Parameters:
    ///   - temperature: 현재 기온 문자열 (예: "22°C")
    ///   - skyInfo: 현재 하늘 상태 정보 (예: "맑음", "흐림")
    func sendCurrentWeatherLocalNotification(temperature: String, skyInfo: String) {
        let content = UNMutableNotificationContent()
        content.title = "현재날씨"
        content.body = "현재 날씨는 \(temperature), \(skyInfo) 입니다."
        
        // 매일 오전 7시에 트리거
        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: 7, minute: 00), repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { (error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("success notification")
            }
        }
    }
}
