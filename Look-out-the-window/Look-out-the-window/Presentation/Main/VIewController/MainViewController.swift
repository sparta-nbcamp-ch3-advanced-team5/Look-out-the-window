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

// TODO: - DetailCell Header, customView 추가
// TODO: - SF Symbol 컬러 세팅
final class MainViewController: UIViewController {
    
    private let mainView = MainView()
    
    private let disposeBag = DisposeBag()
    
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
        
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
               else { return }
        print(apiKey)
    }
    
    
}

extension MainViewController: UICollectionViewDelegate {
    func setRxDataSource() {
        // Delegate 연결
        mainView.collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        // 예시 데이터(Mock)
        let sections = Observable.just([
            MainSection(items: [
                .hourly(HourlyModel(hour: "Now", temperature: "20'C", weatherInfo: "sun.min")),
                .hourly(HourlyModel(hour: "10시", temperature: "21'C", weatherInfo: "sun.horizon.fill")),
                .hourly(HourlyModel(hour: "11시", temperature: "22'C", weatherInfo: "sun.haze.fill")),
                .hourly(HourlyModel(hour: "12시", temperature: "23'C", weatherInfo: "sun.rain.fill")),
                .hourly(HourlyModel(hour: "13시", temperature: "24'C", weatherInfo: "sun.snow.fill")),
                .hourly(HourlyModel(hour: "14시", temperature: "25'C", weatherInfo: "cloud.drizzle.fill")),
                .hourly(HourlyModel(hour: "15시", temperature: "26'C", weatherInfo: "cloud.bolt.rain.fill")),
                .hourly(HourlyModel(hour: "16시", temperature: "27'C", weatherInfo: "sun.max")),
                .hourly(HourlyModel(hour: "17시", temperature: "28'C", weatherInfo: "sun.min"))
            ]),
            MainSection(items: [
                .daily(DailyModel(day: "오늘", high: "35", low: "11", weatherInfo: "sun.min")),
                .daily(DailyModel(day: "화", high: "35", low: "30", weatherInfo: "sun.min")),
                .daily(DailyModel(day: "수", high: "32", low: "27", weatherInfo: "sun.min")),
                .daily(DailyModel(day: "목", high: "29", low: "24", weatherInfo: "sun.min")),
                .daily(DailyModel(day: "금", high: "24", low: "19", weatherInfo: "sun.min")),
                .daily(DailyModel(day: "토", high: "19", low: "14", weatherInfo: "sun.min")),
                .daily(DailyModel(day: "일", high: "16", low: "11", weatherInfo: "sun.min"))
            ]),
            MainSection(items: [
                .detail(DetailModel(title: "자외선지수", value: "높음", weatherInfo: "sun.min")),
                .detail(DetailModel(title: "일출/일몰", value: "05:20/19:45", weatherInfo: "sun.min")),
                .detail(DetailModel(title: "바람", value: "3m/s NW", weatherInfo: "sun.min")),
                .detail(DetailModel(title: "강수량", value: "5mm", weatherInfo: "sun.min")),
                .detail(DetailModel(title: "체감기온", value: "20℃", weatherInfo: "sun.min")),
                .detail(DetailModel(title: "습도", value: "70%", weatherInfo: "sun.min"))
            ])
        ])
        
        // RxDataSources 바인딩
        sections
            .bind(to: mainView.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

