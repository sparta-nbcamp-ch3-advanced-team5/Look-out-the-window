//
//  RegionWeatherListViewModel.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/21/25.
//

import Foundation
import OSLog

import RxRelay
import RxSwift

/// 지역 리스트 ViewModel
final class RegionWeatherListViewModel: ViewModelProtocol {
    
    // MARK: - Properties
    
    private lazy var log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    let disposeBag = DisposeBag()
    
    private let networkManager = NetworkManager()
    
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
        
        let regionWeatherList = PublishRelay<[CurrentWeather]>()
        let currLocationWeather = PublishRelay<CurrentWeather>()
    }
    var state = State()
    
    // MARK: - Initializer
    
    init() {
        state.actionSubject
            .subscribe(with: self) { owner, action in
                switch action {
                case .viewDidLoad:
                    owner.fetchAndUpdateRegionWeatherList()  // CoreData에 있는 데이터 fetch & API 호출을 통한 업데이트
                    owner.updateCurrLocationWeather()  // 이후 API 호출을 통해 현재 위치 업데이트
                }
            }.disposed(by: disposeBag)
    }
}

// MARK: - Weather Methods

private extension RegionWeatherListViewModel {
    func fetchAndUpdateRegionWeatherList() {
        // TODO: CoreData에서 지역 데이터 가져옴
        // - CoreData에서 현재 위치 데이터 있는지 확인
        // - 없으면
        //   - 현재 위치가 nil이 아니면 현재 위치로 셀 새로 생성
        //   - 현재 위치가 nil이면 셀 생성 X
        // - 있으면 현재 위치 셀 업데이트 시도
        //   - 현재 위치가 nil이면 이전 데이터의 위치 데이터를 기반으로 날씨 갱신
        
        // CoreData에 현재 위치 날씨 정보가 없다고 가정
        
        // Mock Data
        let oldWeatherList = mockCoordList
        
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else { return }
        
        let networkRequests: [Single<WeatherResponseDTO>] = oldWeatherList.compactMap { model in
            guard let request = APIEndpoints.getURLRequest(
                .weather,
                parameters: WeatherParameters(
                    lat: model.lat,
                    lng: model.lng,
                    appid: apiKey
                ).makeParameterDict()
            ) else { return nil }
            return networkManager.fetch(urlRequest: request)
        }
        
        Single.zip(networkRequests)
            .subscribe(with: self) { owner, responseDTOList in
                let currentWeatherList = responseDTOList.map { $0.toCurrentWeather() }
                owner.state.regionWeatherList.accept(currentWeatherList)
            } onFailure: { owner, error in
                // TODO: 기존 데이터 전달
//                owner.state.regionWeatherList.accept(oldWeatherList)
                os_log(.error, log: owner.log, "NetworkManager error: \(error.localizedDescription)")
            }.disposed(by: disposeBag)
    }
    
    /// 업데이트된 위치를 기반으로 `RegionWeatherListView`의 현 위치 셀을 업데이트하는 메서드
    func updateCurrLocationWeather() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else { return }
        
        CoreLocationManager.shared.currLocation
            .subscribe(with: self) { owner, currLocation in
                // 현재 위치가 nil이 아니면 업데이트
                // TODO: CoreData에 현재위치인지 식별하는 변수 필요
                guard let currLocation,
                      let request = APIEndpoints.getURLRequest(
                        .weather,
                        parameters: WeatherParameters(
                            lat: currLocation.lat,
                            lng: currLocation.lng,
                            appid: apiKey
                        ).makeParameterDict()
                      ) else { return }
                let networkRequest: Single<WeatherResponseDTO> = owner.networkManager.fetch(urlRequest: request)
                networkRequest
                    .subscribe(with: self) { owner, responseDTO in
                        let currentWeather = responseDTO.toCurrentWeather()
                        owner.state.currLocationWeather.accept(currentWeather)
                    } onFailure: { owner, error in
                        os_log(.error, log: owner.log, "NetworkManager error: \(error.localizedDescription)")
                    }.disposed(by: owner.disposeBag)
            }.disposed(by: disposeBag)
    }
}
