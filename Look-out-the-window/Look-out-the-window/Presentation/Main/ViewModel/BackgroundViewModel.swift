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
    let currentTime: Double
}


final class BackgroundViewModel: ViewModelProtocol {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    private let urlRequest: URLRequest?
    private let networkManager = NetworkManager()
    private let currentLocation = CoreLocationManager.shared.currLocation
    
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
        self.urlRequest = APIEndpoints.getURLRequest(APIEndpoints.weather, parameters: WeatherParameters(lat: currentLocation.lat, lng: currentLocation.lng, appid: Bundle.main.infoDictionary?["API_KEY"] as? String ?? "").makeParameterDict())
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
                    address: self.currentLocation.administrativeArea,
                    temperature: currentWeather.temperature,
                    skyInfo: currentWeather.skyInfo,
                    maxTemp: currentWeather.maxTemp,
                    minTemp: currentWeather.minTemp,
                    rive: currentWeather.rive,
                    currentTime: currentWeather.currentMomentValue
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
