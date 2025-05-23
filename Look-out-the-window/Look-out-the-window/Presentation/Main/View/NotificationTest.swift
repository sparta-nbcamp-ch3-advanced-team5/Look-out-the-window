//
//  NotificationTest.swift
//  Look-out-the-window
//
//  Created by 정근호 on 5/23/25.
//

import UIKit
import UserNotifications
import RxCocoa
import RxSwift
import SnapKit
import Then

class NotificationTest: UIView {
    
    private let disposeBag = DisposeBag()
    
    private let unc = UNUserNotificationCenter.current()
    
    private lazy var notificationButton = UIButton().then {
        $0.setTitle("Notification", for: .normal)
        $0.setTitleColor(.label, for: .normal)
        $0.backgroundColor = .black
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setting Methods
private extension NotificationTest {
    func setupUI() {
        setViewHiearchy()
        setConstraints()
        bind()
    }
    
    func setViewHiearchy() {
        self.addSubview(notificationButton)
    }
    
    func setConstraints() {
        notificationButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind() {
        notificationButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.requestAuthorizationForNotification()
            }).disposed(by: disposeBag)
    }
    
    func requestAuthorizationForNotification() {
        let options = UNAuthorizationOptions([.alert, .badge, .sound])
        unc.requestAuthorization(options: options) { [weak self] success, error in
            guard let self else { return }
            if success {
                self.sendLocalNotification(seconds: 2)
            } else {
                print("알림허용 요청오류: \(error?.localizedDescription ?? "error")")
            }
        }
    }
    
    func sendLocalNotification(seconds: Double) {
        let content = UNMutableNotificationContent()
        content.title = "푸시알림 제목"
        content.body = "푸시알림 테스트 내용입니다."
        content.userInfo = ["targetScene" : "splash" ] // 푸시 받을 때 오는 데이터
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        unc.add(request) { error in
            print(#function, error ?? "nil")
        }
    }
}
