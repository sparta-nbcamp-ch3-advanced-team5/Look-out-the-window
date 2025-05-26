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
        
        let regionWeatherListSectionRelay = BehaviorRelay<[RegionWeatherListSection]>(value: [])
    }
    var state = State()
    
    // MARK: - Initializer
    
    init() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else { return }
        
        CoreLocationManager.shared.currLocationRelay
            .subscribe(with: self) { owner, currLocation in
                // 현재 위치가 nil이 아니면 업데이트
                guard let currLocation,
                      let request = APIEndpoints.getURLRequest(
                        .weather,
                        parameters: WeatherParameters(
                            lat: currLocation.lat,
                            lng: currLocation.lng,
                            appid: apiKey
                        ).makeParameterDict()
                      ) else { return }
                
                let networkRequests: Single<WeatherResponseDTO> = owner.networkManager.fetch(urlRequest: request)
                networkRequests
                    .subscribe(with: self) { owner, responseDTO in
                        let currLocationWeather = responseDTO.toCurrentWeather(address: currLocation.toAddress(), isCurrLocation: true)
                        
                        var regionWeatherListSections = owner.state.regionWeatherListSectionRelay.value
                        
                        // 현 위치에 해당하는 날씨 데이터가 있는지 확인
                        if let regionWeatherListSection = regionWeatherListSections.first {
                           var regionWeatherList = regionWeatherListSection.items
                            // 현 위치 주소와 같은 날씨 데이터가 있는지 확인
                            if let index = regionWeatherList.firstIndex(where: { $0.address == currLocation.toAddress() }) {
                                // 같으면 해당 데이터를 0번째 인덱스로 순서 변경
                                let currLocationWeather = regionWeatherList.remove(at: index)
                                regionWeatherList.insert(currLocationWeather, at: 0)
                                
                                // 새로운 섹션 반영
                                let newRegionWeatherListSections = [RegionWeatherListSection(items: regionWeatherList)]
                                owner.state.regionWeatherListSectionRelay.accept(newRegionWeatherListSections)
                            } else {
                                // 없으면 0번째 인덱스에 현 위치 데이터 추가, 섹션 반영
                                regionWeatherListSections.insert(RegionWeatherListSection(items: [currLocationWeather]), at: 0)
                                owner.state.regionWeatherListSectionRelay.accept(regionWeatherListSections)
                            }
                        }
                        
                        
                    } onFailure: { owner, error in
                        os_log(.error, log: owner.log, "NetworkManager error: \(error.localizedDescription)")
                    }.disposed(by: owner.disposeBag)
            }.disposed(by: disposeBag)
        
        
        state.actionSubject
            .subscribe(with: self) { owner, action in
                switch action {
                case .viewDidLoad:
                    owner.fetchAndUpdateRegionWeatherList()  // CoreData에 있는 데이터 fetch & API 호출을 통한 업데이트
                }
            }.disposed(by: disposeBag)
    }
}

// MARK: - Weather Methods

private extension RegionWeatherListViewModel {
    func fetchAndUpdateRegionWeatherList() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else { return }
        
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
                let regionWeatherList = responseDTOList.map { $0.toCurrentWeather() }
                
                let regionWeatherListSection = RegionWeatherListSection(items: regionWeatherList)
                
                owner.state.regionWeatherListSectionRelay.accept([regionWeatherListSection])
            } onFailure: { owner, error in
                // TODO: 기존 데이터 전달
//                owner.state.regionWeatherListRelay.accept(oldWeatherList)
                os_log(.error, log: owner.log, "NetworkManager error: \(error.localizedDescription)")
            }.disposed(by: disposeBag)
    }
}
