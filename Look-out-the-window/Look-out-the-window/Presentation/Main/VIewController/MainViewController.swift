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

final class MainViewController: UIViewController {
    
    private let mainView = MainView()
    
    private let disposeBag = DisposeBag()
    
    let dataSource = RxCollectionViewSectionedReloadDataSource<MainSection>(
        configureCell: { dataSource, collectionView, indexPath, item in
            switch item {
            case .hourly(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath) as! HourlyCell
                // cell에 model 데이터 바인딩
                return cell
            case .daily(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyCell", for: indexPath) as! DailyCell
                // cell에 model 데이터 바인딩
                return cell
            case .detail(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCell", for: indexPath) as! DetailCell
                // cell에 model 데이터 바인딩
                return cell
            }
        }
    )
    
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
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
        
        // 예시 데이터
        let sections = Observable.just([
            MainSection(items: [
                .hourly(HourlyModel(hour: "09:00", temperature: "20'C")),
                .hourly(HourlyModel(hour: "10:00", temperature: "21'C"))
            ]),
            MainSection(items: [
                .daily(DailyModel(day: "월", high: "25'C", low: "15'C")),
                .daily(DailyModel(day: "화", high: "26'C", low: "16'C"))
            ]),
            MainSection(items: [
                .detail(DetailModel(title: "자외선지수", value: "높음")),
                .detail(DetailModel(title: "일출", value: "05:20")),
                .detail(DetailModel(title: "일몰", value: "19:45")),
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

