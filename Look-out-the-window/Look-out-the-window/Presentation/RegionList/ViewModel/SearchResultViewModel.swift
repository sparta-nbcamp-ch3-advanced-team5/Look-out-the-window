//
//  SearchResultViewModel.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/22/25.
//

import Foundation

import RxSwift

final class SearchResultViewModel: ViewModelProtocol {
    
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
        
    }
}
