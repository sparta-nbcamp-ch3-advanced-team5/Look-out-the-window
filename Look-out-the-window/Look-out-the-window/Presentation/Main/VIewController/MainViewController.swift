//
//  MainViewController.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/20/25.
//

// TODO: - DetailCell Header, customView 추가
// TODO: - SF Symbol 컬러 세팅

/*
 데이터 종류
 temperature: "22", maxTemp: "28", minTemp: "21", tempFeelLike: "23", skyInfo: "구름", pressure: "1006", humidity: "83", clouds: "75", uvi: "0", visibility: "10000", windSpeed: "2", windDeg: "320"
 */

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import SnapKit
import Then
import CoreLocation

final class MainViewController: UIViewController {
    
    private let mainView = MainView()
    private let disposeBag = DisposeBag()
    
    // 네트워크 데이터 바인딩용 Relay
    private let sectionsRelay = BehaviorRelay<[MainSection]>(value: [])
    
    let dataSource = RxCollectionViewSectionedReloadDataSource<MainSection>(
        configureCell: { dataSource, collectionView, indexPath, item in
            switch item {
            case .hourly(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath) as! HourlyCell
                cell.bind(model: model)
                return cell
            case .daily(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyCell", for: indexPath) as! DailyCell
                let isLast = indexPath.item == (collectionView.numberOfItems(inSection: indexPath.section) - 1)
                cell.bind(model: model, isBottom: isLast, totalMin: 10, totalMax: 40)
                return cell
            case .detail(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCell", for: indexPath) as! DetailCell
                cell.bind(model: model)
                return cell
            }
        },
        configureSupplementaryView: { dataSource, collectionView, kind, indexPath -> UICollectionReusableView in
            if indexPath.section == 0 {
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: MainHeaderView.id,
                    for: indexPath
                )
                return header
            } else if indexPath.section == 1 {
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: MainHeaderView.id,
                    for: indexPath
                )
                return header
            }
            return UICollectionReusableView()
        }
    )
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "MainBackground")
        setRxDataSource()
        requestWeatherAndBind()
    }
}

extension MainViewController: UICollectionViewDelegate {
    func setRxDataSource() {
        mainView.collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        sectionsRelay
            .bind(to: mainView.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

// MARK: - 네트워크 요청 및 데이터 변환
private extension MainViewController {
    func requestWeatherAndBind() {
        let networkManager = NetworkManager()
        
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            print("❌ API 키 없음")
            return
        }
        
        let params = WeatherParameters(lat: 37.5665, lng: 126.9780, appid: apiKey)
        guard let request = APIEndpoints.getURLRequest(.weather, parameters: params.makeParameterDict()) else {
            print("❌ URLRequest 생성 실패")
            return
        }
        
        // 1. Task에서 await로 fetch 호출
        Task {
            let single: Single<WeatherResponseDTO> = await networkManager.fetch(urlRequest: request)
            
            // 2. Single을 Rx 체인으로 사용
            single
                .map { dto in
                    print("WeatherResponseDTO 디버깅:\n\(dto)") // MARK: - 디버깅용
                    let weather = dto.toCurrentWeather()
                    return self.convertToMainSections(from: weather)
                }
                .observe(on: MainScheduler.instance)
                .subscribe(onSuccess: { [weak self] sections in
                    self?.sectionsRelay.accept(sections)
                }, onFailure: { error in
                    print("❌ 날씨 요청 실패: \(error)")
                })
                .disposed(by: self.disposeBag)
        }
    }
    
    func convertToMainSections(from weather: CurrentWeather) -> [MainSection] {
        let hourlyItems = weather.hourlyModel.map { MainSectionItem.hourly($0) }
        let dailyItems = weather.dailyModel.map { MainSectionItem.daily($0) }
        
        // detail 섹션 예시 (필요에 따라 수정)
        let detailItems: [MainSectionItem] = [
            .detail(DetailModel(title: "자외선지수", value: weather.uvi, weatherInfo: weather.skyInfo)),
            .detail(DetailModel(title: "일출/일몰", value: "\(weather.sunriseTime)/\(weather.sunsetTime)", weatherInfo: weather.skyInfo)),
            .detail(DetailModel(title: "바람", value: "\(weather.windSpeed)m/s \(weather.windDeg)", weatherInfo: weather.skyInfo)),
            .detail(DetailModel(title: "강수량", value: "-", weatherInfo: weather.skyInfo)),
            .detail(DetailModel(title: "체감기온", value: weather.tempFeelLike, weatherInfo: weather.skyInfo)),
            .detail(DetailModel(title: "습도", value: weather.humidity, weatherInfo: weather.skyInfo))
        ]
        
        return [
            MainSection(items: hourlyItems),
            MainSection(items: dailyItems),
            MainSection(items: detailItems)
        ]
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
