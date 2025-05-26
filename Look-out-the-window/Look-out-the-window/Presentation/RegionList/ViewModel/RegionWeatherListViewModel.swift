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
    
    /// 총 지역 날씨 리스트 Section
    private var totalWeatherListSections = [RegionWeatherListSection]()
    /// 현 위치 날씨 Section
    private var currLocationWeatherSection = RegionWeatherListSection(header: .currLocation, items: [])
    /// 저장된 지역 날씨 리스트 Section
    private var savedRegionWeatherListSection = RegionWeatherListSection(header: .savedRegionList, items: [])
    
    /// Mock Data
    private var oldWeatherList = mockCurrentWeatherList
    
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
                // 현 위치(주소)가 이전과 같으면 ➡️ 매 시간 정각일때만 API 호출
                if let currLocationWeather = owner.currLocationWeatherSection.items.first,
                   currLocation.toAddress() == currLocationWeather.address,
                   Int(Date().timeIntervalSince1970) % 3600 != 0 { return }
                
                // 현재 위치가 nil이 아니면 업데이트
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
                        // 현 위치 데이터 순서 변경용
                        var modifiedRegionWeatherListSection = owner.savedRegionWeatherListSection
                        
                        // 현 위치에 해당하는 날씨 데이터가 있는지 확인하는 과정
                        // 현 위치 주소와 같은 날씨 데이터가 savedRegionWeatherListSection.items에 있는지 확인
                        if let index = modifiedRegionWeatherListSection.items.firstIndex(where: { $0.address == currLocation.toAddress() }) {
                            // 같으면 해당 데이터의 인덱스를 0번째로 교체 및 isCurrLocation를 true로 변경
                            var currLocationWeatherItem = modifiedRegionWeatherListSection.items.remove(at: index)
                            currLocationWeatherItem.isCurrLocation = true
                            owner.currLocationWeatherSection.items = [currLocationWeatherItem]
                            
                            // savedRegionWeatherList를 Relay에 accept
                            owner.totalWeatherListSections = [owner.currLocationWeatherSection, modifiedRegionWeatherListSection]
                        } else {
                            // 없으면 currLocationWeatherSection에 현 위치 데이터 추가, 섹션 반영
                            owner.currLocationWeatherSection.items = [currLocationResponse]
                            owner.totalWeatherListSections = [owner.currLocationWeatherSection, owner.savedRegionWeatherListSection]
                        }
                        
                        owner.state.regionWeatherListSectionRelay.accept(owner.totalWeatherListSections)
                        os_log(.debug, log: owner.log, "현 위치 날씨 updated \(currLocationResponse.address)")
                    } onFailure: { owner, error in
                        os_log(.error, log: owner.log, "NetworkManager error: \(error.localizedDescription)")
                    }.disposed(by: owner.disposeBag)
                
            }.disposed(by: disposeBag)
        
        
        state.actionSubject
            .subscribe(with: self) { owner, action in
                switch action {
                case .viewDidLoad:
                    owner.fetchAndUpdateRegionWeatherList()  // CoreData에 있는 데이터 fetch & API 호출을 통한 업데이트
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
        
        // CoreData에 현재 위치 날씨 정보가 없다고 가정
        
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
                let regionWeatherResponseList = responseDTOList.enumerated().map { $0.element.toCurrentWeather(address: owner.oldWeatherList[$0.offset].address) }
                owner.savedRegionWeatherListSection.items = regionWeatherResponseList
                // 현 위치 데이터 순서 변경용
                var modifiedRegionWeatherListSection = RegionWeatherListSection(header: .savedRegionList, items: regionWeatherResponseList)
                
                // 현 위치에 해당하는 날씨 데이터가 API로부터 전달받은 데이터에 있는지 확인하는 과정
                if let currLocation = CoreLocationManager.shared.currLocationRelay.value,
                   let index = regionWeatherResponseList.firstIndex(where: { $0.address == currLocation.toAddress() }) {
                    var currLocationWeatherResponse = modifiedRegionWeatherListSection.items.remove(at: index)
                    currLocationWeatherResponse.isCurrLocation = true
                    owner.currLocationWeatherSection.items = [currLocationWeatherResponse]
                }
                
                owner.totalWeatherListSections = [owner.currLocationWeatherSection, modifiedRegionWeatherListSection]
                owner.state.regionWeatherListSectionRelay.accept(owner.totalWeatherListSections)
                os_log(.debug, log: owner.log, "저장된 지역 날씨 updated: \(regionWeatherResponseList.count)개")
            } onFailure: { owner, error in
                // TODO: 기존 데이터 전달
                os_log(.error, log: owner.log, "NetworkManager error: \(error.localizedDescription)")
                owner.state.regionWeatherListSectionRelay.accept(owner.totalWeatherListSections)
            }.disposed(by: disposeBag)
    }
    
    func deleteRegionWeather(indexPath: IndexPath) {
        savedRegionWeatherListSection.items.remove(at: indexPath.row)
        totalWeatherListSections = [currLocationWeatherSection, savedRegionWeatherListSection]
        state.regionWeatherListSectionRelay.accept(totalWeatherListSections)
    }
}
