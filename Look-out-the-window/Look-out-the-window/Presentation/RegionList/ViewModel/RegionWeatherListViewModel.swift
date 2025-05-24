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
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else { return }
        
        let requests: [Single<WeatherResponseDTO>] = regionWeatherList.compactMap { model -> Single<WeatherResponseDTO>? in
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
        
        Single.zip(requests)
            .subscribe(with: self) { owner, responses in
                var newRegionWeatherList = [RegionWeatherModel]()
                for (index, response) in responses.enumerated() {
                    
                    let currentWeather = response.toCurrentWeather()
                    newRegionWeatherList.append(RegionWeatherModel(temp: currentWeather.temperature,
                                                                   maxTemp: currentWeather.maxTemp,
                                                                   minTemp: currentWeather.minTemp,
                                                                   location: regionWeatherList[index].location,
                                                                   rive: currentWeather.rive,
                                                                   weather: currentWeather.skyInfo,
                                                                   updateTime: currentWeather.currentTime.convertUnixToHourMinuteAndMark(),
                                                                   lat: regionWeatherList[index].lat,
                                                                   lng: regionWeatherList[index].lng))
                }
                owner.state.regionWeatherList.accept(newRegionWeatherList)
            } onFailure: { owner, error in
                os_log(.error, log: owner.log, "NetworkManager error: \(error.localizedDescription)")
            }.disposed(by: disposeBag)
        
        // 현재 위치가 nil이 아니면 리스트에 표시
//        if let currLocation = CoreLocationManager.shared.currLocation.value {
//
//        }
    }
}
