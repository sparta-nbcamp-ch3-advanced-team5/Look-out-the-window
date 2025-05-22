//
//  BackgroundViewController.swift
//  Look-out-the-window
//
//  Created by 정근호 on 5/20/25.
//

import UIKit

import RxSwift
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
    
    // Mock Model
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
    /// 밝기관련 뷰 시간에 따라 어두워짐.
    private let dimView = UIView()
    /// 배경 Gradient
    private let gradientLayer = CAGradientLayer()
    
    private lazy var backgroundViewList = [BackgroundTopInfoView]()
    
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
    }
}

// MARK: - Setting Methods
private extension BackgroundViewController {
    func setupUI() {
        setAppearance()
        setViewHiearchy()
        setConstraints()
        
        setBackgroundViews()
    }
    
    func setAppearance() {
        // 리스트의 초기값으로 첫 화면 설정
        applyGradientBackground(time: weatherInfoList[0].time)
    }
    
    func setViewHiearchy() {
        view.addSubviews(dimView, scrollView, pageController, locationButton, listButton)
        
        scrollView.addSubview(scrollContentView)
    }
    
    func setConstraints() {
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        scrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
    
    func bind() {
        // 스크롤의 감속이 끝났을 때 페이징
        scrollView.rx.didEndDecelerating
            .map { [weak self] _ -> Int in
                guard let scrollView = self?.scrollView else { return 0 }
                // scrollView 내부 콘첸트가 수평으로 얼마나 스크롤 됐는지 / scrollView가 화면에 차지하는 너비
                let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
                return page
            }
            .distinctUntilChanged() // 중복 방지
            .do(onNext: { [weak self] in
                guard let self else { return }
                self.applyGradientBackground(time: self.weatherInfoList[$0].time)
            })
            .bind(to: pageController.rx.currentPage)
            .disposed(by: disposeBag)
        
        // 페이지 컨트롤 클릭 시 페이징
        // 기본적으로 페이지 컨트롤 클릭 시 페이지 값이 변경되어 .valueChaned로 구현
        pageController.rx.controlEvent(.valueChanged)
            .map { [weak self] _ -> Int in
                guard let self else { return 0 }
                let page = self.pageController.currentPage
                return page
            }
            .subscribe(onNext: { [weak self] page in
                guard let self else { return }
                let offsetX = Int(self.scrollView.frame.width) * page
                self.scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
                self.applyGradientBackground(time: self.weatherInfoList[page].time)
            })
            .disposed(by: disposeBag)
    }
    
    /// backgroundView 레이아웃 설정
    func setBackgroundViews() {
        for (index, weatherInfo) in weatherInfoList.enumerated() {
            let backgroundView = BackgroundTopInfoView(frame: .zero, weatherInfo: weatherInfo)
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
    }
    
    /// Gradient, 밝기 설정
    func applyGradientBackground(time: Double) {
        gradientLayer.colors = [ UIColor.mainBackground1.cgColor, UIColor.secondaryBackground.cgColor ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        //        gradientLayer.locations = [0.4, 0.6]
        gradientLayer.frame = view.bounds
        dimView.backgroundColor = .black.withAlphaComponent(normalizeAndClamp(time, valueMin: 0.0, valueMax: 10.0, targetMin: 0.0, targetMax: 0.5))
        // 배경이니 제일 하단에 위치하도록
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    /// 특정 값을 주어진 범위(targetMin~targetMax) 사이의 값으로 변환.
    /// - valueMin,valueMax: input 되는 값의 범위.
    /// - targetMin, targetMax: return 되는 값의 범위.
    func normalizeAndClamp(
        _ value: Double,
        valueMin: Double,
        valueMax: Double,
        targetMin: Double,
        targetMax: Double) -> Double
    {
        let ratio = (value - valueMin) / (valueMax - valueMin)
        
        let scaledValue = targetMin + ratio * (targetMax - targetMin)
        
        let clampedValue = max(targetMin, min(scaledValue, targetMax))
        
        print(value, clampedValue)
        return clampedValue
    }
}
