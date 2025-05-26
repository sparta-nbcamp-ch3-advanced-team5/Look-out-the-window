//
//  MainViewController.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/20/25.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import SnapKit
import Then
import CoreLocation

/*
 HourlyModel - temperature -> ex) 14.78 -> 15 (소수점 포맷팅 필요)
 DailyModel - day(월요일 -> 월) high, low->  ex) 14.78 -> 15 (소수점 포맷팅 필요)
 
 -> 요일 제외 온도 소수점 포맷팅 완료
 
 DetailModel - 잘 판단이 안됨.... 팀원 협의
 */

// TODO: - DetailCell Header, customView 추가
// TODO: - CoreData 관련 로직 추가

final class MainViewController: UIViewController {
    
    private let mainView = MainView()
    private let disposeBag = DisposeBag()
    
    private var totalMinTemp = 0
    private var totalMaxTemp = 0
    
    // 네트워크 데이터 바인딩용 Relay
    private let sectionsRelay = BehaviorRelay<[MainSection]>(value: [])
    
    lazy var dataSource = RxCollectionViewSectionedReloadDataSource<MainSection>(
        configureCell: { dataSource, collectionView, indexPath, item in
            switch item {
            case .hourly(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath) as! HourlyCell
                cell.bind(model: model)
                return cell
            case .daily(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyCell", for: indexPath) as! DailyCell
                let isLast = indexPath.item == (collectionView.numberOfItems(inSection: indexPath.section) - 1)
                cell.bind(model: model, isBottom: isLast, totalMin: self.totalMinTemp, totalMax: self.totalMaxTemp)
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
        self.view.backgroundColor = .mainBackground
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
        
        // TODO: - Location 정보 관련 로직 필요
        let params = WeatherParameters(lat: 37.5665, lng: 126.9780, appid: apiKey)
        guard let request = APIEndpoints.getURLRequest(.weather, parameters: params.makeParameterDict()) else {
            print("❌ URLRequest 생성 실패")
            return
        }
        
        // Task에서 await로 fetch 호출
        Task {
            let single: Single<WeatherResponseDTO> = await networkManager.fetch(urlRequest: request)
            
            // Single을 Rx 체인으로 사용
            single
                .map { dto in
                    print("🔥WeatherResponseDTO 디버깅:\n\(dto)🔥") // MARK: - 디버깅용
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
        // HourlyModel 포맷팅
        let formattedHourlyModels = weather.hourlyModel.map { model in
            HourlyModel(
                hour: model.hour,
                temperature: "\(Double(model.temperature)?.roundedString ?? model.temperature)°",
                weatherInfo: model.weatherInfo
            )
        }
        let hourlyItems = formattedHourlyModels.map { MainSectionItem.hourly($0) }

        // DailyModel 포맷팅
        let formattedDailyModels = weather.dailyModel.map { model in
            DailyModel(
                day: model.day,
                high: Double(model.high)?.roundedString ?? model.high,
                low: Double(model.low)?.roundedString ?? model.low,
                weatherInfo: model.weatherInfo
            )
        }
        // 전체 기간 최저/최고 기온 계산
        let dailyHighs = formattedDailyModels.compactMap { Int($0.high) }
        let dailyLows = formattedDailyModels.compactMap { Int($0.low) }
        
        totalMaxTemp = dailyHighs.max() ?? 0
        totalMinTemp = dailyLows.min() ?? 0
        
        // dailyItems 생성 (이 값들을 dataSource에도 전달)
        let dailyItems = formattedDailyModels.map { MainSectionItem.daily($0) }
        
        
        // 디버깅용 프린트
        formattedHourlyModels.debugPrintModelArray(title: "HourlyModel")
        formattedDailyModels.debugPrintModelArray(title: "DailyModel")
        
        // DetailModel은 동일하게 사용
        let detailModels: [DetailModel] = [
            DetailModel(title: "자외선지수", value: weather.uvi, weatherInfo: weather.skyInfo),
            DetailModel(title: "일출/일몰", value: "\(weather.sunriseTime)/\(weather.sunsetTime)", weatherInfo: weather.skyInfo),
            DetailModel(title: "바람", value: "\(weather.windSpeed)m/s \(weather.windDeg)", weatherInfo: weather.skyInfo),
            DetailModel(title: "강수량", value: "-", weatherInfo: weather.skyInfo),
            DetailModel(title: "체감기온", value: weather.tempFeelLike, weatherInfo: weather.skyInfo),
            DetailModel(title: "습도", value: weather.humidity, weatherInfo: weather.skyInfo)
        ]
        detailModels.debugPrintModelArray(title: "DetailModel")
        let detailItems = detailModels.map { MainSectionItem.detail($0) }

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

// MARK: - 디버깅용
extension HourlyModel: CustomStringConvertible {
    var description: String {
        "☠️[hour: \(hour), temperature: \(temperature), weatherInfo: \(weatherInfo)]☠️"
    }
}

extension DailyModel: CustomStringConvertible {
    var description: String {
        "☠️[day: \(day), high: \(high), low: \(low), weatherInfo: \(weatherInfo)]☠️"
    }
}

extension DetailModel: CustomStringConvertible {
    var description: String {
        "☠️[title: \(title), value: \(value), weatherInfo: \(weatherInfo)]☠️"
    }
}

// 배열을 프린트하는 함수
extension Array where Element: CustomStringConvertible {
    func debugPrintModelArray(title: String) {
        print("☠️🔎 \(title) (\(self.count)개)☠️")
        self.forEach { print($0) }
    }
}
