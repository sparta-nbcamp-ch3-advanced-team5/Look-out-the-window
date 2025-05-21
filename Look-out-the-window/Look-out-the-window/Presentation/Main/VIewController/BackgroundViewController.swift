//
//  BackgroundViewController.swift
//  Look-out-the-window
//
//  Created by 정근호 on 5/20/25.
//

import UIKit

import RxCocoa
import RxSwift
import RxGesture
import SnapKit
import Then
import RiveRuntime

struct WeatherInfo {
    let city: String
    let temperature: Int
    let weather: String
    let highestTemp: Int
    let lowestTemp: Int
    let rive: String
    let time: Double
}

final class BackgroundViewController: UIViewController {
    
    private let weatherInfoList: [WeatherInfo] = [
        WeatherInfo(city: "부산", temperature: 20, weather: "약간 흐림", highestTemp: 22, lowestTemp: 18, rive: Rive.partlyCloudy, time: 0.0),
        WeatherInfo(city: "서울", temperature: 18, weather: "맑음", highestTemp: 21, lowestTemp: 16, rive: Rive.sunny, time: 3.0),
        WeatherInfo(city: "제주", temperature: 21, weather: "눈", highestTemp: 24, lowestTemp: 19, rive: Rive.snow, time: 5.0),
        WeatherInfo(city: "인천", temperature: 19, weather: "비", highestTemp: 20, lowestTemp: 17, rive: Rive.rainy, time: 7.0),
        WeatherInfo(city: "강원", temperature: 19, weather: "천둥", highestTemp: 21, lowestTemp: 18, rive: Rive.thunder, time: 9.0),
        WeatherInfo(city: "광주", temperature: 19, weather: "흐림", highestTemp: 22, lowestTemp: 19, rive: Rive.cloudy, time: 10.0)
    ]
    
    private let viewModel: BackgroundViewModel
    
    let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private lazy var backgroundViewList = [BackgroundView]()
    
    private lazy var scrollView = UIScrollView().then {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let scrollContentView = UIView()
    
    private lazy var locationButton = UIButton().then {
        // 버튼의 SFSymbol 이미지 크기 변경 시 사용
        //        let config = UIImage.SymbolConfiguration(pointSize: 44, weight: .regular)
        $0.setImage(UIImage(systemName: "location.fill", withConfiguration: nil), for: .normal)
        $0.tintColor = .label
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    private lazy var listButton = UIButton().then {
        //        let config = UIImage.SymbolConfiguration(pointSize: 44, weight: .regular)
        $0.setImage(UIImage(systemName: "list.bullet", withConfiguration: nil), for: .normal)
        $0.tintColor = .label
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    private lazy var pageController = UIPageControl().then {
        $0.numberOfPages = weatherInfoList.count
        $0.currentPage = 0
        $0.currentPageIndicatorTintColor = .white
        $0.pageIndicatorTintColor = .systemGray
    }
    
    // MARK: - Initializers
    init(viewModel: BackgroundViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        
        guard let apiKeyEncoding = Bundle.main.object(forInfoDictionaryKey: "API_KEY_ENCODING") as? String,
              let apiKeyDecoding = Bundle.main.object(forInfoDictionaryKey: "API_KEY_DECODING") as? String,
              let clientId = Bundle.main.object(forInfoDictionaryKey: "CLIENT_ID") as? String,
              let clientSecret = Bundle.main.object(forInfoDictionaryKey: "CLIENT_SECRET") as? String else { return }
        print(apiKeyEncoding)
        print(apiKeyDecoding)
        print(clientId)
        print(clientSecret)
    }
    
    // MARK: - UI & Layout
    private func setupUI() {
        view.addSubviews(scrollView, pageController, locationButton, listButton)
        
        scrollView.addSubview(scrollContentView)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        scrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        for (index, weatherInfo) in weatherInfoList.enumerated() {
            let backgroundView = BackgroundView(frame: .zero, weatherInfo: weatherInfo)
            scrollContentView.addSubview(backgroundView)
            backgroundViewList.append(backgroundView)
            
            backgroundView.snp.makeConstraints {
                $0.verticalEdges.equalToSuperview()
                $0.width.equalTo(view.snp.width)
                $0.leading.equalToSuperview().offset(CGFloat(index) * UIScreen.main.bounds.width)
            }
        }
        
        if let lastBackgroundView = backgroundViewList.last {
            lastBackgroundView.snp.makeConstraints {
                $0.trailing.equalToSuperview()
            }
        }
                
        pageController.snp.makeConstraints {
            $0.centerY.equalTo(locationButton)
            $0.centerX.equalToSuperview()
        }
        
        locationButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.width.height.equalTo(44)
        }
        
        listButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.width.height.equalTo(44)
        }
    }
    
    
    
    // MARK: - Private Methods
    private func bind() {
        
        scrollView.rx.didEndDecelerating
            .map { [weak self] _ -> Int in
                guard let scrollView = self?.scrollView else { return 0 }
                print(scrollView.contentOffset.x, scrollView.frame.width)
                // scrollView 내부 콘첸트가 수평으로 얼마나 스크롤 됐는지 / scrollView가 화면에 차지하는 너비
                let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
                return page
            }
            .distinctUntilChanged() // 중복 방지
            .bind(to: pageController.rx.currentPage)
            .disposed(by: disposeBag)
    }
}
