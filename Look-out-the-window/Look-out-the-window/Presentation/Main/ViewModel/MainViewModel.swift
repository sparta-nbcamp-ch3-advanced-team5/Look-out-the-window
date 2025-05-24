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
        case fetchWeatherIfNeeded(LocationModel)
    }
    var action: AnyObserver<Action> {
        return state.actionSubject.asObserver()
    }

    // MARK: - State (ViewModel ➡️ ViewController)

    struct State {
        let actionSubject = PublishSubject<Action>()
        let savedWeather = BehaviorSubject<[WeatherDataEntity]>(value: [])
    }
    var state = State()

    /*
     //MARK: -- 주형 질문: 어떤 값을 받아야하는지?
     let administrativeArea: String
     let locality: String
     let subLocality: String
     let areasOfInterest: String
     */
    //주형: 네트워크 요청하여 saveData
    private func saveOrUpdateWeather(for location: LocationModel) {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            return
        }
        let parameters = WeatherParameters(lat: location.lat, lng: location.lng, appid: apiKey).makeParameterDict()

        //와 엔드포인트랑 구조체 만드는 법 많이 배웠습니다.
        guard let request = APIEndpoints.getURLRequest(.weather, parameters: parameters) else {
            return
        }

        Task {
            let single: Single<WeatherResponseDTO> = await NetworkManager().fetch(urlRequest: request)

            single
                .subscribe(onSuccess: { response in
                    let current = response.toCurrentWeather()
                    CoreDataManager.shared.saveWeatherData(current: current, latitude: location.lat, longitude: location.lng)

//                    CoreDataManager.shared.saveLatLngAppStarted(current: current,
//                                                          latitude: location.lat,
//                                                          longitude: location.lng)
                }, onFailure: { error in
                    print("\(error.localizedDescription)")
                })
                .disposed(by: disposeBag)
        }
    }

    func loadSavedWeatherData() {
        let saved = CoreDataManager.shared.fetchWeatherData()
        state.savedWeather.onNext(saved)
    }


    // MARK: - Initializer

    init() {
        state.actionSubject
            .subscribe(with: self) { owner, action in
                switch action {
                case .fetchWeatherIfNeeded(let location):
                    owner.saveOrUpdateWeather(for: location)
                }
            }.disposed(by: disposeBag)

        state.savedWeather
             .observe(on: MainScheduler.instance)
             .subscribe(onNext: { savedList in
                 print("🟢 CoreData에서 불러온 데이터 \(savedList.count)건")

                 // ✅ TODO: 테이블 뷰에 연결 시 reloadData 또는 diffable datasource 사용
                 savedList.forEach { weather in
                     print("🌍 \(weather.latitude), \(weather.longitude) | \(weather.temperature ?? "-")º ")
                 }

                 // 예: self?.tableView.reloadData() or self?.adapter.applySnapshot(...)
             })
             .disposed(by: disposeBag)
    }
}
