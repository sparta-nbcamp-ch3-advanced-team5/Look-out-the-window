//
//  BackgroundViewModel.swift
//  Look-out-the-window
//
//  Created by 정근호 on 5/20/25.
//

import Foundation

import RxRelay
import RxSwift

final class WeatherDetailViewModel: ViewModelProtocol {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var weatherInfoList = [CurrentWeather]()
    
    private let urlRequest: URLRequest?
    private let networkManager = NetworkManager()
    private let currentLocation = CoreLocationManager.shared.currLocationRelay
    private let coreDataManager = CoreDataManager.shared
    private var latestWeather: CurrentWeather?
    
    
    // MARK: - Action (ViewController ➡️ ViewModel)
    
    enum Action {
        case getCurrentWeather
        case pullToRefresh
    }
    var action: AnyObserver<Action> {
        return state.actionSubject.asObserver()
    }
    
    // MARK: - State (ViewModel ➡️ ViewController)
    
    struct State {
        /// ViewController에서 받은 action
        private(set) var actionSubject = PublishSubject<Action>()
        /// 현재 날씨
        private(set) var currentWeather = PublishRelay<CurrentWeather>()
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
                case .pullToRefresh:
                    owner.getCurrentWeatherData()
                    owner.saveToCoreData()
                }
            }.disposed(by: disposeBag)
    }

    //현재 날씨를 전달하는 릴레이가 CurrentWeather로 바껴서 엔티티 저장을 구조를 변경함
//    init(entity: WeatherDataEntity) {
//        self.urlRequest = nil
//        let model = entity.toCurrentWeatherModel()
//        state.currentWeather.accept(model)
//    }
}

//MARK: - Extension Private Methods
extension WeatherDetailViewModel {
    // MARK: - 네트워크 요청 및 섹션 데이터 변환
    // 네트워크 요청 및 데이터 변환
    func getCurrentWeatherData() {
        networkManager.fetch(urlRequest: urlRequest!)
            .subscribe(with: self, onSuccess: { (owner, response: WeatherResponseDTO)  in
                
                let currentWeather = response.toCurrentWeather()
                let weatherInfo = CurrentWeather(
                    address: self.currentLocation.value?.administrativeArea ?? "",
                    lat: currentWeather.lat,
                    lng: currentWeather.lng,
                    currentTime: currentWeather.currentTime,
                    currentMomentValue: currentWeather.currentMomentValue,
                    sunriseTime: currentWeather.sunriseTime,
                    sunsetTime: currentWeather.sunsetTime,
                    temperature: currentWeather.temperature,
                    maxTemp: currentWeather.maxTemp,
                    minTemp: currentWeather.minTemp,
                    tempFeelLike: currentWeather.tempFeelLike,
                    skyInfo: currentWeather.skyInfo,
                    pressure: currentWeather.pressure,
                    humidity: currentWeather.humidity,
                    clouds: currentWeather.clouds,
                    uvi: currentWeather.uvi,
                    visibility: currentWeather.visibility,
                    windSpeed: currentWeather.windSpeed,
                    windDeg: currentWeather.windDeg,
                    rive: currentWeather.rive,
                    hourlyModel: currentWeather.hourlyModel,
                    dailyModel: currentWeather.dailyModel,
                    isCurrLocation: true,
                    rainPerHour: currentWeather.rainPerHour,
                    snowPerHour: currentWeather.snowPerHour
                )
                
                print("지역: \(String(describing: weatherInfo.address))")
                print("현재 온도: \(weatherInfo.temperature)")
                print("현재 날씨: \(weatherInfo.skyInfo)")
                print("최고 온도: \(weatherInfo.maxTemp)")
                print("최저 온도: \(weatherInfo.minTemp)")
                print("Rive: \(weatherInfo.rive)")
                print("현재 시간: \(weatherInfo.currentTime)")
                print("Moment: \(currentWeather.currentMomentValue)")
                
                self.latestWeather = weatherInfo
                owner.state.currentWeather.accept(weatherInfo)
                
            }, onFailure: { owner, error  in
                print("에러 발생: \(error)")
            })
            .disposed(by: self.disposeBag)
    }
    
    func convertToMainSections(from weather: CurrentWeather) -> [MainSection] {
        let formattedHourlyModels = weather.hourlyModel
            .prefix(24)
            .map { model in
                HourlyModel(
                    hour: model.hour.to24HourInt(),
                    temperature: "\(Double(model.temperature)?.roundedString ?? model.temperature)°",
                    weatherInfo: model.weatherInfo
                )
            }
        let hourlyItems = formattedHourlyModels.map { MainSectionItem.hourly($0) }
        
        let formattedDailyModels = weather.dailyModel.map { model in
            DailyModel(
                unixTime: model.unixTime,
                day: String(model.day.prefix(1)),
                high: Double(model.high)?.roundedString ?? model.high,
                low: Double(model.low)?.roundedString ?? model.low,
                weatherInfo: model.weatherInfo,
                maxTemp: model.maxTemp,
                minTemp: model.minTemp,
                temperature: model.temperature
            )
        }
        
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
    
    func saveToCoreData() {
        guard let currentWeather = latestWeather else {
            print("저장할 날씨 데이터가 없습니다.")
            return
        }
        // 추후에 updateWeatherData로 변경
        coreDataManager.saveWeatherData(current: currentWeather)
    }
    
}

// MARK: - 디버깅 용으로 임의로 만들었습니다
extension WeatherResponseDTO: CustomStringConvertible {
    var description: String {
        """
        --- WeatherResponseDTO ---
        lat: \(lat)
        lng: \(lng)
        timeZone: \(timeZone)
        timeZoneOffset: \(timeZoneOffset)
        currentWeather: \(currentWeather)
        minutelyRains: \(minutelyRains.count)개
        hourlyWeathers: \(hourlyWeathers.count)개
        dailyWeathers: \(dailyWeathers.count)개
        -------------------------
        """
    }
}
