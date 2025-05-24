//
//  BackgroundViewModel.swift
//  Look-out-the-window
//
//  Created by 정근호 on 5/20/25.
//

import Foundation

import RxRelay
import RxSwift

struct WeatherInfo {
    let address: String
    let temperature: String
    let skyInfo: String
    let maxTemp: String
    let minTemp: String
    let rive: String
    let currentTime: Int
}


final class BackgroundViewModel: ViewModelProtocol {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    private let urlRequest = APIEndpoints.getURLRequest(APIEndpoints.weather, parameters: WeatherParameters(lat: 35.137752, lng: 129.10258, appid: Bundle.main.infoDictionary?["API_KEY"] as? String ?? "").makeParameterDict())
    private let networkManager = NetworkManager()
    
    // MARK: - Action (ViewController ➡️ ViewModel)
    
    enum Action {
        case getCurrentWeather
        case appendWeatherInfo
    }
    var action: AnyObserver<Action> {
        return state.actionSubject.asObserver()
    }
    
    // MARK: - State (ViewModel ➡️ ViewController)
    
    struct State {
        /// ViewController에서 받은 action
        private(set) var actionSubject = PublishSubject<Action>()
        /// 현재 날씨
        private(set) var currentWeather = PublishSubject<WeatherInfo>()
        /// 날씨 리스트
        private(set) var weatherInfoList = BehaviorRelay<[WeatherInfo]>(value: [])
    }
    var state = State()
    
    // MARK: - Initializer
    
    init() {
        state.actionSubject
            .subscribe(with: self) { owner, action in
                switch action {
                case .getCurrentWeather:
                    owner.getCurrentWeatherData()
                case .appendWeatherInfo:
                    owner.appendToWeatherInfoList()
                }
            }.disposed(by: disposeBag)
    }
}

//MARK: - Extension Private Methods
private extension BackgroundViewModel {
    
    func getCurrentWeatherData() {
        networkManager.fetch(urlRequest: urlRequest!)
            .subscribe(with: self, onSuccess: { (owner, response: WeatherResponseDTO)  in
                
                let currentWeather = response.toCurrentWeather()
                let weatherInfo = WeatherInfo(
                    address: currentWeather.address ?? "지역",
                    temperature: currentWeather.temperature,
                    skyInfo: currentWeather.skyInfo,
                    maxTemp: currentWeather.maxTemp,
                    minTemp: currentWeather.minTemp,
                    rive: currentWeather.rive,
                    currentTime: currentWeather.currentTime
                )
                print("지역: \(weatherInfo.address)")
                print("현재 온도: \(weatherInfo.temperature)")
                print("현재 날씨: \(weatherInfo.skyInfo)")
                print("최고 온도: \(weatherInfo.maxTemp)")
                print("최저 온도: \(weatherInfo.minTemp)")
                print("Rive: \(weatherInfo.rive)")
                print("현재 시간: \(weatherInfo.currentTime)")
                print("Moment: \(currentWeather.currentMomentValue)")
                
                owner.state.currentWeather.onNext(weatherInfo)
                
            }, onFailure: { owner, error  in
                print("에러 발생: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    func appendToWeatherInfoList() {
        
    }
}
