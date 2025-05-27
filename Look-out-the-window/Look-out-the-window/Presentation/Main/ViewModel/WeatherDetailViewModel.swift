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


final class WeatherDetailViewModel: ViewModelProtocol {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    private let urlRequest: URLRequest?
    private let networkManager = NetworkManager()
    private let currentLocation = CoreLocationManager.shared.currLocationRelay
    
    var weatherInfoList = [WeatherInfo]()
    
    // MARK: - Action (ViewController ➡️ ViewModel)
    
    enum Action {
        case getCurrentWeather
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
    }
    var state = State()
    
    // MARK: - Initializer
    
    init() {
        // URLRequset 설정
        self.urlRequest = APIEndpoints.getURLRequest(APIEndpoints.weather, parameters: WeatherParameters(
            lat: currentLocation.value?.lat ?? 0.0,
            lng: currentLocation.value?.lng ?? 0.0,
            appid: Bundle.main.infoDictionary?["API_KEY"] as? String ?? "").makeParameterDict())
        
        state.actionSubject
            .subscribe(with: self) { owner, action in
                switch action {
                case .getCurrentWeather:
                    owner.getCurrentWeatherData()
                }
            }.disposed(by: disposeBag)
    }
}

//MARK: - Extension Private Methods
private extension WeatherDetailViewModel {
    
    func getCurrentWeatherData() {
        networkManager.fetch(urlRequest: urlRequest!)
            .subscribe(with: self, onSuccess: { (owner, response: WeatherResponseDTO)  in
                
                let currentWeather = response.toCurrentWeather()
                let weatherInfo = WeatherInfo(
                    address: self.currentLocation.value?.administrativeArea ?? "",
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
}
