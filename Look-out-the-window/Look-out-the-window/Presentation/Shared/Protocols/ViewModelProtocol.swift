//
//  ViewModelProtocol.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/20/25.
//

import Foundation

import RxSwift

/// ViewModel이 준수하는 프로토콜
protocol ViewModelProtocol {
    /// `ViewModel`이 처리할 수 있는 사용자 이벤트를 정의합니다.
    associatedtype Action
    /// `ViewController`가 구독하는 `ViewModel`의 상태 스트림을 보유합니다.
    /// 각 프로퍼티는 UI 바인딩을 위한 업데이트를 발행합니다.
    associatedtype State
    
    var disposeBag: DisposeBag { get }
    /// Action을 주입받을 통로
    var action: AnyObserver<Action> { get }
    /// `View` 쪽에 전달되는 상태 스트림
    var state: State { get }
}
