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
    associatedtype Action
    associatedtype State
    
    var disposeBag: DisposeBag { get }
    /// Action을 주입받을 통로
    var action: AnyObserver<Action> { get }
    /// View 쪽에 전달되는 상태 스트림
    var state: State { get }
}
