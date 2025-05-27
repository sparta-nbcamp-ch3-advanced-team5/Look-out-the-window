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
    
    private var totalWeatherListFromCoreData = [CurrentWeather]()
    
    // MARK: - Action (ViewController ➡️ ViewModel)
    
    enum Action {
        case viewDidLoad
        case regionRegistered
        case itemDeleted(indexPath: IndexPath)
        case update
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
                // 현 위치가 totalWeatherListFromCoreData.items에 존재하는 경우
                if let savedCurrWeather = owner.totalWeatherListFromCoreData.filter({ $0.address == currLocation.toAddress() }).first {
                    // 마지막 업데이트로부터 10분 이상 지날때마다 API 호출
                    if Int(Date().timeIntervalSince1970) < savedCurrWeather.currentTime + 600 {
                        return
                    }
                }
                
                // 10분 이상 지났거나, 현 위치가 nil이 아니면 API 호출을 통한 업데이트 실시
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
                        var currLocationResponse = responseDTO.toCurrentWeather(address: currLocation.toAddress(), isCurrLocation: true, isUserSaved: false)
                        
                        if let index = owner.totalWeatherListFromCoreData.firstIndex(where: { $0.isCurrLocation == true }) {
                            // 기존에 isCurrLocation이 true였던 항목을 찾음
                            if currLocationResponse.address == owner.totalWeatherListFromCoreData[index].address {
                                // 업데이트된 현 위치의 주소가 기존 항목과 동일하면 해당 데이터 업데이트
                                currLocationResponse.isUserSaved = owner.totalWeatherListFromCoreData[index].isUserSaved
                                owner.totalWeatherListFromCoreData[index] = currLocationResponse
                                CoreDataManager.shared.updateWeather(for: owner.totalWeatherListFromCoreData[index].address, with: owner.totalWeatherListFromCoreData[index])
                            } else {
                                // 기존 항목과 동일하지 않다면
                                if owner.totalWeatherListFromCoreData[index].isUserSaved == false {
                                    // 기존 항목이 사용자가 저장한 항목이 아니라면 삭제
                                    let deleteWeather = owner.totalWeatherListFromCoreData.remove(at: index)
                                    CoreDataManager.shared.deleteWeather(for: deleteWeather.address)
                                } else {
                                    // 기존 항목이 사용자가 저장한 항목이라면 isCurrLocation을 false로 변경
                                    owner.totalWeatherListFromCoreData[index].isCurrLocation = false
                                    CoreDataManager.shared.updateWeather(for: owner.totalWeatherListFromCoreData[index].address, with: owner.totalWeatherListFromCoreData[index])
                                }
                                // 별도로 추가
                                owner.totalWeatherListFromCoreData.append(currLocationResponse)
                                CoreDataManager.shared.saveWeatherData(current: currLocationResponse)
                            }
                        } else {
                            // 기존에 isCurrLocation이 true였던 항목이 없으면 별도로 추가
                            owner.totalWeatherListFromCoreData.append(currLocationResponse)
                            CoreDataManager.shared.saveWeatherData(current: currLocationResponse)
                        }
                        
                        // isCurrLocation == true로 sort
                        let sortedWeatherList = owner.totalWeatherListFromCoreData.sorted(by: owner.isCurrLocationSort)
                        
                        // UI에 표시
                        owner.state.regionWeatherListSectionRelay.accept([RegionWeatherListSection(header: .regionList, items: sortedWeatherList)])
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
                case .regionRegistered:
                    owner.fetchAndUpdateRegionWeatherList()
                case .update:
                    owner.fetchAndUpdateRegionWeatherList()
                }
            }.disposed(by: disposeBag)
    }
}

// MARK: - Data Methods

private extension RegionWeatherListViewModel {
    /// CoreData에 저장되어있는 날씨 fetch & update
    func fetchAndUpdateRegionWeatherList() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else { return }
        
        // - CoreData에서 현재 위치 데이터 있는지 확인
        // - 없으면
        //   - 현재 위치가 nil이 아니면 현재 위치로 셀 새로 생성
        //   - 현재 위치가 nil이면 셀 생성 X
        // - 있으면 현재 위치 셀 업데이트 시도
        //   - 현재 위치가 nil이면 이전 데이터의 위치 데이터를 기반으로 날씨 갱신
        
        // CoreData에서 날씨 데이터 fetch
        totalWeatherListFromCoreData = CoreDataManager.shared.fetchWeatherData().map({ $0.toCurrentWeatherModel() })
        let sortedWeatherList = totalWeatherListFromCoreData.sorted(by: isCurrLocationSort)
        
        // UI에 표시
        state.regionWeatherListSectionRelay.accept([RegionWeatherListSection(header: .regionList, items: sortedWeatherList)])
        
        // CoreData에 저장된 모든 지역에 대해 API 호출 통한 날씨 데이터 업데이트
        let networkRequests: [Single<WeatherResponseDTO>] = totalWeatherListFromCoreData.compactMap { model in
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
                    $0.element.toCurrentWeather(address: owner.totalWeatherListFromCoreData[$0.offset].address, isCurrLocation: false)
                }

                // 현 위치에 해당하는 API 날씨 데이터의 isCurrLocation 최신화
                if let currLocation = CoreLocationManager.shared.currLocationRelay.value,
                   let index = regionWeatherResponseList.firstIndex(where: { $0.address == currLocation.toAddress() }) {
                    regionWeatherResponseList[index].isCurrLocation = true
                }
                owner.totalWeatherListFromCoreData = regionWeatherResponseList
                
                // isCurrLocation == true로 sort
                let sortedWeatherList = owner.totalWeatherListFromCoreData.sorted(by: owner.isCurrLocationSort)
                
                // UI에 표시
                owner.state.regionWeatherListSectionRelay.accept([RegionWeatherListSection(header: .regionList, items: sortedWeatherList)])
                
                // CoreData에 isCurrLocation 최신화된 API 날씨 데이터 저장
                owner.totalWeatherListFromCoreData.forEach {
                    CoreDataManager.shared.updateWeather(for: $0.address, with: $0)
                }
                
                os_log(.debug, log: owner.log, "저장된 지역 날씨 updated: \(regionWeatherResponseList.count)개")
            } onFailure: { owner, error in
                os_log(.error, log: owner.log, "NetworkManager error: \(error.localizedDescription)")
            }.disposed(by: disposeBag)
    }
    
    func deleteRegionWeather(indexPath: IndexPath) {
        var showingWeatherList = state.regionWeatherListSectionRelay.value[0].items
        let deletedRegion = showingWeatherList.remove(at: indexPath.row)
        let sortedWeatherList = showingWeatherList.sorted(by: isCurrLocationSort)
        state.regionWeatherListSectionRelay.accept([RegionWeatherListSection(header: .regionList, items: sortedWeatherList)])
        
        CoreDataManager.shared.deleteWeather(for: deletedRegion.address)
    }
    
    /// `isCurrLocation == true`인 날씨 데이터부터 먼저 보여주기 위한 정렬 메서드
    func isCurrLocationSort(_ model1: CurrentWeather, _ model2: CurrentWeather) -> Bool {
        return model1.isCurrLocation == true && model2.isCurrLocation == false
    }
}

// CoreData 불러옴 -> isCurrLocation == true로 sort -> accept -> API 호출 -> isCurrLocation 최신화 -> CoreData 저장 -> isCurrLocation == true로 sort -> accept
