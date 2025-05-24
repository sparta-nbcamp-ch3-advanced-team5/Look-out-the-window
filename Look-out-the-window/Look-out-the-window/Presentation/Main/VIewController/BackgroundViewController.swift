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


final class BackgroundViewController: UIViewController {
    
    // Mock Model
    private let viewModel: BackgroundViewModel
    private let disposeBag = DisposeBag()
    private var previousPage = 0
    private var weatherInfoList = [WeatherInfo]()
    
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
        
        bindViewModel()
        setupUI()
        setupPagination()
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
    
//    func setAppearance() {
//        // 리스트의 초기값으로 첫 화면 설정
//        if !weatherInfoList.isEmpty {
//            applyGradientBackground(time: Double(weatherInfoList[0].currentTime))
//        }
//    }
    
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
            $0.height.equalTo(scrollView.snp.height)
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
    
    func setupPagination() {
        
        // 스크롤의 감속이 끝났을 때 페이징
        scrollView.rx.didEndDecelerating
            .map { [weak self] _ -> Int in
                guard let self else { return 0 }
                let currentPage = self.pageController.currentPage
                // scrollView 내부 콘첸트가 수평으로 얼마나 스크롤 됐는지 / scrollView가 화면에 차지하는 너비
                let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
                // 페이징 직전 페이지 rive 중지
                backgroundViewList[currentPage].riveViewModel.pause()
                return page
            }
            .do(onNext: { [weak self] page in
                guard let self else { return }
                self.applyGradientBackground(time: Double(self.weatherInfoList[page].currentTime))
                // 페이징 후 페이지 rive 재생
                backgroundViewList[page].riveViewModel.play()
            })
            .bind(to: pageController.rx.currentPage)
            .disposed(by: disposeBag)
        
        // 페이지 컨트롤 클릭 시 페이징
        // 기본적으로 페이지 컨트롤 클릭 시 페이지 값이 변경되어 .valueChaned로 구현
        pageController.rx.controlEvent(.valueChanged)
            .map { [weak self] _ -> Int in
                guard let self else { return 0 }
                let currentPage = self.pageController.currentPage
                return currentPage
            }
            .subscribe(onNext: { [weak self] currentPage in
                guard let self else { return }
                
                // 이전 페이지 정지, 현재 페이지 재생
                backgroundViewList[previousPage].riveViewModel.pause()
                backgroundViewList[currentPage].riveViewModel.play()
                
                let offsetX = Int(self.scrollView.frame.width) * currentPage
                self.scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
                self.applyGradientBackground(time: Double(self.weatherInfoList[currentPage].currentTime))
                
                // 이전 페이지 업데이트
                self.previousPage = currentPage
            })
            .disposed(by: disposeBag)
    }
    
    /// backgroundView 레이아웃 설정
    func setBackgroundViews() {
        
        if !backgroundViewList.isEmpty {
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
            
            // 첫번째 뷰 rive play
            backgroundViewList[0].riveViewModel.play()
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
        
        return clampedValue
    }
    
    func bindViewModel() {
        viewModel.action.onNext(.getCurrentWeather)
        
        viewModel.state.currentWeather
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (weather) in
                guard let self else { return }
                self.weatherInfoList.append(weather)
                self.reloadUI(with: weather)
            }).disposed(by: disposeBag)
    }
    
    func reloadUI(with weather: WeatherInfo) {
        let index = weatherInfoList.count - 1
        
        // Background View 추가
        let backgroundView = BackgroundTopInfoView(frame: .zero, weatherInfo: weather)
        scrollContentView.addSubview(backgroundView)
        backgroundViewList.append(backgroundView)
        
        backgroundView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.width.equalTo(view.snp.width)
            $0.leading.equalToSuperview().offset(CGFloat(index) * UIScreen.main.bounds.width)
        }
        
        if let last = backgroundViewList.last {
            last.snp.makeConstraints {
                $0.trailing.equalToSuperview()
            }
        }
        
        // pageController 업데이트
        pageController.numberOfPages = weatherInfoList.count
        
        // 첫 번째 뷰일 경우 재생 및 배경 적용
        if index == 0 {
            backgroundView.riveViewModel.play()
            applyGradientBackground(time: Double(weather.currentTime))
        }
    }
}
 
