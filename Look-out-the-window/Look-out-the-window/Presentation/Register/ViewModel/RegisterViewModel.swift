//
//  RegisterViewModel.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/26/25.
//

import Foundation

import RxSwift
import RxRelay

final class RegisterViewModel: ViewModelProtocol {
    
    let disposeBag = DisposeBag()
    private let networkManager = NetworkManager()
    
    enum Action {
        case viewDidLoad
        case plusButtonTapped
    }
    
    struct State {
        var actionSubject = PublishSubject<Action>()
        let currentWeather = BehaviorRelay<[MainSection]>(value: [])
    }
    
    var action: AnyObserver<Action> {
        return state.actionSubject.asObserver()
    }
    
    var state = State()
    
    init(address: String, lat: Double, lng: Double) {
        state.actionSubject
            .subscribe(with: self) { owner, action in
                switch action {
                case .viewDidLoad:
                    owner.fetchWeather(address: address, lat: lat, lng: lng)
                case .plusButtonTapped:
                    print("plusButtonTapped")
                }
            }.disposed(by: disposeBag)
    }
    
    func fetchWeather(address: String, lat: Double, lng: Double) {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else { return }
        // MARK: lat, lng 파라미터로 수정할 것.
        let weatherParameters = WeatherParameters(lat: 33.260706, lng: 126.560002, appid: apiKey)
        let parameters = weatherParameters.makeParameterDict()
        let request = APIEndpoints.getURLRequest(.weather, parameters: parameters)
        networkManager.fetch(urlRequest: request!)
            .subscribe(with: self, onSuccess: { (owner, response: WeatherResponseDTO) in
                print("hi")
                let weather = response.toCurrentWeather(address: address, isCurrLocation: false)
                owner.state.currentWeather.accept(owner.convertToMainSections(from: weather))
                
            }, onFailure: {owner, error in
                print(error.localizedDescription)
            }).disposed(by: disposeBag)
            
    }
}

extension RegisterViewModel {
    func convertToMainSections(from weather: CurrentWeather) -> [MainSection] {
        let formattedHourlyModels = weather.hourlyModel
            .prefix(24) // 앞에서 24개만 사용
            .map { model in
                HourlyModel(
                    hour: model.hour.to24HourInt(),
                    temperature: "\(Double(model.temperature)?.roundedString ?? model.temperature)°",
                    weatherInfo: model.weatherInfo
                )
            }
        let hourlyItems = formattedHourlyModels.map { MainSectionItem.hourly($0) }
        
        // DailyModel 포맷팅
        let formattedDailyModels = weather.dailyModel.map { model in
            DailyModel(
                unixTime: model.unixTime,
                day: String(model.day.prefix(1)),
                high: Double(model.high)?.roundedString ?? model.high,
                low: Double(model.low)?.roundedString ?? model.low,
                weatherInfo: model.weatherInfo,
                maxTemp: model.minTemp,
                minTemp: model.maxTemp
            )
        }
        
        // dailyItems 생성 (이 값들을 dataSource에도 전달)
        let dailyItems = formattedDailyModels.map { MainSectionItem.daily($0) }

        let detailModels: [DetailModel] = [
            DetailModel(title: .uvIndex, value: weather.uvi),
            DetailModel(title: .sunriseSunset, value: "\(weather.sunriseTime)/\(weather.sunsetTime)"),
            DetailModel(title: .wind, value: "\(weather.windSpeed)m/s \(weather.windDeg)"),
            DetailModel(title: .rainSnow, value: "-"),
            DetailModel(title: .feelsLike, value: weather.tempFeelLike),
            DetailModel(title: .humidity, value: weather.humidity),
            DetailModel(title: .visibility, value: weather.visibility),
            DetailModel(title: .clouds, value: weather.clouds)
        ]
        let detailItems = detailModels.map { MainSectionItem.detail($0) }
        
        return [
            MainSection(items: hourlyItems),
            MainSection(items: dailyItems),
            MainSection(items: detailItems)
        ]
    }
}
