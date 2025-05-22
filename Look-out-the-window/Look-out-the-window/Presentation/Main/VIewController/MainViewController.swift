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

// cell.configure메서드에 isBottom
// 온도 변경 될때마다 layout이 변경될 여지가 있음 -> monospacedDigitSystemFont(ofSize: , weight:) 시스템 폰트 대신

// TODO: - DetailCell Header, customView 추가 // Daily Header 추가, 레이아웃 수정
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
                cell.bind(model: model)
                return cell
            case .detail(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCell", for: indexPath) as! DetailCell
                
                return cell
            }
        },
        // TODO: - Daily Section Header 추가
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
                .daily(DailyModel(day: "오늘", high: "20'C", low: "30'C", weatherInfo: "sun.min")),
                .daily(DailyModel(day: "화", high: "21'C", low: "31'C", weatherInfo: "sun.min")),
                .daily(DailyModel(day: "수", high: "22'C", low: "32'C", weatherInfo: "sun.min")),
                .daily(DailyModel(day: "목", high: "23'C", low: "33'C", weatherInfo: "sun.min")),
                .daily(DailyModel(day: "금", high: "24'C", low: "34'C", weatherInfo: "sun.min")),
                .daily(DailyModel(day: "토", high: "25'C", low: "35'C", weatherInfo: "sun.min")),
                .daily(DailyModel(day: "일", high: "26'C", low: "36'C", weatherInfo: "sun.min"))
            ]),
            MainSection(items: [
                .detail(DetailModel(title: "자외선지수", value: "높음")),
                .detail(DetailModel(title: "일출/일몰", value: "05:20/19:45")),
                .detail(DetailModel(title: "바람", value: "3m/s NW")),
                .detail(DetailModel(title: "강수량", value: "5mm")),
                .detail(DetailModel(title: "체감기온", value: "20℃")),
                .detail(DetailModel(title: "습도", value: "70%"))
            ])
        ])
        
        // RxDataSources 바인딩
        sections
            .bind(to: mainView.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

