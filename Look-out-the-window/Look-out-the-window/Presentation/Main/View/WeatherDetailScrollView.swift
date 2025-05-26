//
//  WeatherDetailScrollView.swift
//  Look-out-the-window
//
//  Created by 정근호 on 5/26/25.
//

import Foundation

import UIKit

import SnapKit
import Then
import RxSwift
import RxDataSources

final class WeatherDetailScrollView: UIView {
    
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
    
    // MARK: - UI Components
    private lazy var verticalScrollView = UIScrollView().then {
        $0.isPagingEnabled = false
        $0.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        }
    }
    private lazy var verticalScrollContentView = UIView()
    var backgroundView: BackgroundTopInfoView
    private lazy var mainView = MainView()
    private lazy var topLoadingIndicatorView = LoadingIndicatorView()
    
    
    init(frame: CGRect, weather: WeatherInfo) {
        self.backgroundView = BackgroundTopInfoView(frame: .zero, weatherInfo: weather)
        super.init(frame: frame)
        
        setupUI()
        bindUIEvents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension WeatherDetailScrollView {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
        setRxDataSource(mainView: mainView)
    }

    func setViewHierarchy() {
        addSubview(verticalScrollView)
        verticalScrollView.addSubviews(topLoadingIndicatorView, verticalScrollContentView)
        verticalScrollContentView.addSubviews(backgroundView, mainView)
    }
    
    func setConstraints() {
        verticalScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        topLoadingIndicatorView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
            $0.top.equalTo(verticalScrollView.snp.top).inset(-50)
        }
        
        verticalScrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(UIScreen.main.bounds.height * 2.8)
        }
        
        backgroundView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(UIScreen.main.bounds.height * 0.6)
        }
        
        mainView.snp.makeConstraints {
            $0.top.equalTo(backgroundView.riveView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func bindUIEvents() {
        verticalScrollView.rx.contentOffset
            .skip(10)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { owner, offset in
                if offset.y < -60 && !owner.verticalScrollView.isDragging {
                    UIView.animate(withDuration: 0.2) {
                        owner.verticalScrollView.contentInset.top = 50
                    }
                    owner.topLoadingIndicatorView.play()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        UIView.animate(withDuration: 0.2) {
                            owner.verticalScrollView.contentInset.top = 0
                        }
                        owner.topLoadingIndicatorView.pause()
                    }
                }
            }.disposed(by: disposeBag)
    }
}

// MARK: - UICollectionViewDelegate
extension WeatherDetailScrollView: UICollectionViewDelegate {
    func setRxDataSource(mainView: MainView) {
        // Delegate 연결
        mainView.collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        // 예시 데이터(Mock)
        let sections = Observable.just([
            MainSection(items: [
                .hourly(HourlyModel(hour: 13, temperature: "20'C", weatherInfo: "sun.min")),
                .hourly(HourlyModel(hour: 14, temperature: "21'C", weatherInfo: "sun.horizon.fill")),
                .hourly(HourlyModel(hour: 15, temperature: "22'C", weatherInfo: "sun.haze.fill")),
                .hourly(HourlyModel(hour: 16, temperature: "23'C", weatherInfo: "sun.rain.fill")),
                .hourly(HourlyModel(hour: 17, temperature: "24'C", weatherInfo: "sun.snow.fill")),
                .hourly(HourlyModel(hour: 18, temperature: "25'C", weatherInfo: "cloud.drizzle.fill")),
                .hourly(HourlyModel(hour: 19, temperature: "26'C", weatherInfo: "cloud.bolt.rain.fill")),
                .hourly(HourlyModel(hour: 20, temperature: "27'C", weatherInfo: "sun.max")),
                .hourly(HourlyModel(hour: 21, temperature: "28'C", weatherInfo: "sun.min"))
            ]),
            MainSection(items: [
                .daily(DailyModel(unixTime: 1748232000, day: "오늘", high: "35", low: "11", weatherInfo: "sun.min")),
                .daily(DailyModel(unixTime: 1748318400, day: "화", high: "35", low: "30", weatherInfo: "sun.min")),
                .daily(DailyModel(unixTime: 1748404800, day: "수", high: "32", low: "27", weatherInfo: "sun.min")),
                .daily(DailyModel(unixTime: 1748491200, day: "목", high: "29", low: "24", weatherInfo: "sun.min")),
                .daily(DailyModel(unixTime: 1748577600, day: "금", high: "24", low: "19", weatherInfo: "sun.min")),
                .daily(DailyModel(unixTime: 1748664000, day: "토", high: "19", low: "14", weatherInfo: "sun.min")),
                .daily(DailyModel(unixTime: 1748750400, day: "일", high: "16", low: "11", weatherInfo: "sun.min"))
            ]),
            MainSection(items: [
                .detail(DetailModel(title: "자외선지수", value: "1", weatherInfo: "sun.min")),
                .detail(DetailModel(title: "자외선지수", value: "4", weatherInfo: "sun.min")),
                .detail(DetailModel(title: "자외선지수", value: "6", weatherInfo: "sun.min")),
                .detail(DetailModel(title: "자외선지수", value: "10", weatherInfo: "sun.min")),
                .detail(DetailModel(title: "자외선지수", value: "11", weatherInfo: "sun.min")),
                .detail(DetailModel(title: "자외선지수", value: "15", weatherInfo: "sun.min")),
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
