//
//  RegisterViewModel.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/26/25.
//

import Foundation

import RxSwift
import RxRelay

/// 등록 화면에서 날씨 정보를 처리하고 상태를 관리하는 ViewModel
/// 사용자 위치 기반으로 날씨 정보를 가져오고, CoreData에 저장하는 역할을 수행함
final class RegisterViewModel: ViewModelProtocol {
    
    // MARK: - Properties

    /// Rx 메모리 정리를 위한 DisposeBag
    let disposeBag = DisposeBag()
    
    /// 네트워크 통신을 담당하는 매니저 객체
    private let networkManager = NetworkManager()
    
    /// 뷰에서 발생할 수 있는 액션 정의
    enum Action {
        case viewDidLoad             // 뷰가 로드되었을 때
        case plusButtonTapped       // 플러스 버튼이 눌렸을 때
    }

    /// ViewModel이 관리하는 상태(State)
    struct State {
        /// 사용자 액션을 처리하기 위한 Subject
        var actionSubject = PublishSubject<Action>()
        
        /// 날씨 정보를 표현하기 위한 메인 섹션 데이터
        let weatherMainSections = BehaviorRelay<[MainSection]>(value: [])
        
        /// 현재 위치의 날씨 데이터
        let currentWeather = BehaviorRelay<CurrentWeather?>(value: nil)
    }

    /// 외부에서 액션을 전달받기 위한 옵저버
    var action: AnyObserver<Action> {
        return state.actionSubject.asObserver()
    }

    /// 상태 저장용 구조체 인스턴스
    var state = State()

    // MARK: - Initializer

    /// 초기화 시 주소 및 좌표 정보를 전달받아 사용
    /// - Parameters:
    ///   - address: 해당 위치의 주소 (지명)
    ///   - lat: 위도
    ///   - lng: 경도
    init(address: String, lat: Double, lng: Double) {
        // 액션을 구독하고 각 케이스별 로직 실행
        state.actionSubject
            .subscribe(with: self) { owner, action in
                switch action {
                case .viewDidLoad:
                    owner.fetchWeather(address: address, lat: lat, lng: lng)
                case .plusButtonTapped:
                    owner.saveCurrentWeather()
                }
            }.disposed(by: disposeBag)
    }

    // MARK: - Networking

    /// 네트워크를 통해 날씨 정보를 요청하고 상태를 갱신
    /// - Parameters:
    ///   - address: 위치 이름 (지명)
    ///   - lat: 위도
    ///   - lng: 경도
    func fetchWeather(address: String, lat: Double, lng: Double) {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else { return }

        let weatherParameters = WeatherParameters(lat: lat, lng: lng, appid: apiKey)
        let parameters = weatherParameters.makeParameterDict()
        let request = APIEndpoints.getURLRequest(.weather, parameters: parameters)

        networkManager.fetch(urlRequest: request!)
            .subscribe(
                with: self,
                onSuccess: { (owner, response: WeatherResponseDTO   ) in
                    let weather = response.toCurrentWeather(address: address, isCurrLocation: false)
                    owner.state.weatherMainSections.accept(weather.toMainSections())
                    owner.state.currentWeather.accept(weather)
                },
                onFailure: { owner, error in
                    print(error.localizedDescription)
                }
            ).disposed(by: disposeBag)
    }

    // MARK: - CoreData

    /// 현재 날씨 정보를 CoreData에 저장
    func saveCurrentWeather() {
        guard var currentWeather = state.currentWeather.value else { return }
        currentWeather.isUserSaved = true
        CoreDataManager.shared.saveWeatherData(current: currentWeather)
    }
}
