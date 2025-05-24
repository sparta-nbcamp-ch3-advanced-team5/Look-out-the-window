//
//  RegionWeatherListViewModel.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/21/25.
//

import Foundation

import RxRelay
import RxSwift

/// 지역 리스트 ViewModel
final class RegionWeatherListViewModel: ViewModelProtocol {
    
    // MARK: - Properties
    
    let disposeBag = DisposeBag()
    
    // MARK: - Action (ViewController ➡️ ViewModel)
    
    enum Action {
        case viewDidLoad
        
    }
    var action: AnyObserver<Action> {
        return state.actionSubject.asObserver()
    }
    
    // MARK: - State (ViewModel ➡️ ViewController)
    
    struct State {
        let actionSubject = PublishSubject<Action>()
        
        let regionWeatherList = PublishRelay<[RegionWeatherModel]>()
    }
    var state = State()
    
    // MARK: - Initializer
    
    init() {
        state.actionSubject
            .subscribe(with: self) { owner, action in
                switch action {
                case .viewDidLoad:
                    owner.getRegionWeatherList()
                }
            }.disposed(by: disposeBag)
    }
}

// MARK: - Weather Methods

private extension RegionWeatherListViewModel {
    func getRegionWeatherList() {
        // TODO: CoreData에서 지역 데이터 가져옴
        // Mock Data
        let regionWeatherList = regionWeatherList_Mock
        
        // TODO: OpenWeather API 호출
//        NetworkManager.fetch(<#T##self: NetworkManager##NetworkManager#>)
        
        // 현재 위치가 nil이 아니면 리스트에 표시
        if let currLocation = CoreLocationManager.shared.currLocation.value {
            
        }
    }
}
