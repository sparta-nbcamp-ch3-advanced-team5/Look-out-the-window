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
                owner.state.currentWeather.accept(weather.toMainSections())
                
            }, onFailure: {owner, error in
                print(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
}
