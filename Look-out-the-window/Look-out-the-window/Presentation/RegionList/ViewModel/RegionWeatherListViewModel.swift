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
    
    private var currLocationWeather = [CurrentWeather]()
    private var weatherListFromCoreData = [CurrentWeather]()
    
    // MARK: - Action (ViewController ➡️ ViewModel)
    
    enum Action {
        case viewDidLoad
        case itemDeleted(indexPath: IndexPath)
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
            .compactMap { $0 }
            .subscribe(with: self) { owner, currLocation in
                // 현 위치가 CoreData에 존재하는 경우 ➡️ 매 시간 정각일때만 API 호출
                if owner.weatherListFromCoreData.contains(where: { $0.address == currLocation.toAddress() }),
                   Int(Date().timeIntervalSince1970) % 3600 != 0 { return }
                
                // 현 위치가 nil이 아니면 업데이트
                guard let request = APIEndpoints.getURLRequest(
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
                        let currLocationResponse = responseDTO.toCurrentWeather(address: currLocation.toAddress(), isCurrLocation: true)
                        
                        // API 날씨 데이터(현 위치)가 weatherListFromCoreData에 있는지 확인
                        if let currLocationindex = owner.weatherListFromCoreData.firstIndex(where: { $0.address == currLocation.toAddress() }) {
                            // 이전 현 위치 데이터의 isCurrLocation을 false로 변경
                            let oldCurrLocationWeather = owner.weatherListFromCoreData.filter { $0.isCurrLocation == true }
                            oldCurrLocationWeather.forEach {
                                var updated = $0
                                updated.isCurrLocation = false
                                CoreDataManager.shared.updateWeather(for: $0.address, with: updated)
                            }
                            
                            // 현 위치에 해당하는 CoreData 날씨 데이터의 isCurrLocation 최신화
                            owner.weatherListFromCoreData[currLocationindex].isCurrLocation = true
                            let currLocationWeather = owner.weatherListFromCoreData[currLocationindex]
                            CoreDataManager.shared.updateWeather(for: currLocationWeather.address, with: currLocationWeather)
                            owner.currLocationWeather = []
                            
                        } else {
                            // 없으면 currLocationWeather에 저장
                            owner.currLocationWeather = [currLocationResponse]
                        }
                        
                        // isCurrLocation == true로 sort
                        let sortedWeatherList = owner.weatherListFromCoreData.sorted(by: owner.isCurrLocationSort)
                        
                        // UI에 표시
                        owner.state.regionWeatherListSectionRelay.accept([RegionWeatherListSection(header: .regionList, items: owner.currLocationWeather + sortedWeatherList)])
                        os_log(.debug, log: owner.log, "현 위치 날씨 updated \(currLocationResponse.address)")
                    } onFailure: { owner, error in
                        os_log(.error, log: owner.log, "NetworkManager error: \(error.localizedDescription)")
                    }.disposed(by: owner.disposeBag)
            }.disposed(by: disposeBag)
        
        
        state.actionSubject
            .subscribe(with: self) { owner, action in
                switch action {
                case .viewDidLoad:
                    owner.fetchAndUpdateRegionWeatherList()
                case let .itemDeleted(indexPath):
                    owner.deleteRegionWeather(indexPath: indexPath)
                }
            }.disposed(by: disposeBag)
    }
}

// MARK: - Data Methods

private extension RegionWeatherListViewModel {
    func fetchAndUpdateRegionWeatherList() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else { return }
        
        // TODO: CoreData에서 지역 데이터 가져옴
        // TODO: CoreData 타임스탬프 확인
        // - CoreData에서 현재 위치 데이터 있는지 확인
        // - 없으면
        //   - 현재 위치가 nil이 아니면 현재 위치로 셀 새로 생성
        //   - 현재 위치가 nil이면 셀 생성 X
        // - 있으면 현재 위치 셀 업데이트 시도
        //   - 현재 위치가 nil이면 이전 데이터의 위치 데이터를 기반으로 날씨 갱신
        
        // CoreData에서 날씨 데이터 fetch
        weatherListFromCoreData = CoreDataManager.shared.fetchWeatherData().map { $0.toCurrentWeatherModel() }
        // isCurrLocation == true로 sort
        let sortedWeatherList = weatherListFromCoreData.sorted(by: isCurrLocationSort)
        // UI에 표시
        state.regionWeatherListSectionRelay.accept([RegionWeatherListSection(header: .regionList, items: sortedWeatherList)])
        
        // API 호출 통한 날씨 데이터 업데이트
        let networkRequests: [Single<WeatherResponseDTO>] = weatherListFromCoreData.compactMap { model in
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
                var regionWeatherResponseList = responseDTOList.enumerated().map {
                    $0.element.toCurrentWeather(address: owner.weatherListFromCoreData[$0.offset].address)
                }

                // 현 위치에 해당하는 API 날씨 데이터의 isCurrLocation 최신화
                if let currLocation = CoreLocationManager.shared.currLocationRelay.value,
                   let index = regionWeatherResponseList.firstIndex(where: { $0.address == currLocation.toAddress() }) {
                    owner.currLocationWeather = []
                    regionWeatherResponseList[index].isCurrLocation = true
                }
                
                // CoreData에 isCurrLocation 최신화된 API 날씨 데이터 저장
                owner.weatherListFromCoreData = regionWeatherResponseList
                CoreDataManager.shared.deleteAll()
                owner.weatherListFromCoreData.forEach {
                    CoreDataManager.shared.saveWeatherData(current: $0)  // TODO: NSBatchInsertRequest
                }
                
                // isCurrLocation == true로 sort
                let sortedAPIWeatherList = owner.weatherListFromCoreData.sorted(by: owner.isCurrLocationSort)
                
                // UI에 표시
                owner.state.regionWeatherListSectionRelay.accept([RegionWeatherListSection(header: .regionList, items: sortedAPIWeatherList)])
                os_log(.debug, log: owner.log, "저장된 지역 날씨 updated: \(regionWeatherResponseList.count)개")
            } onFailure: { owner, error in
                os_log(.error, log: owner.log, "NetworkManager error: \(error.localizedDescription)")
            }.disposed(by: disposeBag)
    }
    
    func deleteRegionWeather(indexPath: IndexPath) {
        let deletedRegion = weatherListFromCoreData.remove(at: indexPath.row)
        let sortedWeatherList = weatherListFromCoreData.sorted(by: isCurrLocationSort)
        state.regionWeatherListSectionRelay.accept([RegionWeatherListSection(header: .regionList, items: sortedWeatherList)])
        
        CoreDataManager.shared.deleteWeather(for: deletedRegion.address)
    }
    
    /// `isCurrLocation == true`인 날씨 데이터부터 먼저 보여주기 위한 정렬 메서드
    func isCurrLocationSort(_ model1: CurrentWeather, _ model2: CurrentWeather) -> Bool {
        return model1.isCurrLocation == true && model2.isCurrLocation == false
    }
}

// CoreData 불러옴 -> isCurrLocation == true로 sort -> accept -> API 호출 -> isCurrLocation 최신화 -> CoreData 저장 -> isCurrLocation == true로 sort -> accept
