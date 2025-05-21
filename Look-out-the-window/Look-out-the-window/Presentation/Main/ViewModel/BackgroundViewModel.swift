//
//  BackgroundViewModel.swift
//  Look-out-the-window
//
//  Created by 정근호 on 5/20/25.
//

import Foundation

import RxRelay
import RxSwift

final class BackgroundViewModel: ViewModelProtocol {
    
    // MARK: - Properties
    
    let disposeBag = DisposeBag()
    
    // MARK: - Action (ViewController ➡️ ViewModel)
    
    enum Action {
        
    }
    var action: AnyObserver<Action> {
        return state.actionSubject.asObserver()
    }
    
    // MARK: - State (ViewModel ➡️ ViewController)
    
    struct State {
        let actionSubject = PublishSubject<Action>()
    }
    var state = State()
    
    // MARK: - Initializer
    
    init() {
        state.actionSubject
            .subscribe(with: self) { owner, action in
                switch action {
                    
                }
            }.disposed(by: disposeBag)
    }
}
