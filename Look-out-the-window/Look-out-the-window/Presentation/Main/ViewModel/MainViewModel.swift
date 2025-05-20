//
//  MainViewModel.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/20/25.
//

import Foundation

import RxRelay
import RxSwift

final class MainViewModel: ViewModelProtocol {
    
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
