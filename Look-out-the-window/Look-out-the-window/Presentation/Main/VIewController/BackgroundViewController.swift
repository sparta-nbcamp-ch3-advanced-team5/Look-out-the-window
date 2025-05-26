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
import RxDataSources
import RxCocoa


final class BackgroundViewController: UIViewController {
    
    private let viewModel: BackgroundViewModel
    private let disposeBag = DisposeBag()
    private var previousPage = 0
    private var weatherInfoList = [WeatherInfo]()
    
    
    // MARK: - UI Components
    private let dataSource = RxCollectionViewSectionedReloadDataSource<MainSection>(
        configureCell: { dataSource, collectionView, indexPath, item in
            switch item {
            case .hourly(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath) as! HourlyCell
                cell.bind(model: model, isFirst: indexPath.item == 0)
                return cell
            case .daily(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyCell", for: indexPath) as! DailyCell
                let isLast = indexPath.item == (collectionView.numberOfItems(inSection: indexPath.section) - 1)
                cell.bind(model: model, isFirst: indexPath.item == 0, isBottom: isLast, totalMin: 10, totalMax: 40)
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
    
    /// 밝기관련 뷰 시간에 따라 어두워짐.
    private let dimView = UIView()
    /// 배경 Gradient
    private let gradientLayer = CAGradientLayer()
    
    private lazy var topLoadingIndicatorView = LoadingIndicatorView()
    
    private lazy var backgroundViewList = [BackgroundTopInfoView]()
    
    private lazy var scrollView = UIScrollView().then {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        // 스크롤 뷰 상단으로 튀지 않도록 자동 조정 방지
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        }
    }
    
    private let scrollContentView = UIView()
    
    private lazy var bottomSepartorView = UIView().then {
        $0.backgroundColor = .secondaryLabel
    }
    
    private lazy var bottomHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
    }
    
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
    
    private lazy var loadingIndicatorView = UIActivityIndicatorView(style: .large).then {
        $0.hidesWhenStopped = true
        $0.color = .white
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
        
        loadingIndicatorView.startAnimating()
        bindViewModel()
        setupUI()
        bindUIEvents()
    }
}

// MARK: - Setting Methods
private extension BackgroundViewController {
    func setupUI() {
        setViewHiearchy()
        setConstraints()
        //        setInitalBackgroundViews()
    }
    
    //    func setAppearance() {
    //        // 리스트의 초기값으로 첫 화면 설정
    //        if !weatherInfoList.isEmpty {
    //            applyGradientBackground(time: Double(weatherInfoList[0].currentTime))
    //        }
    //    }
    
    func setViewHiearchy() {
        view.addSubviews(dimView, scrollView, bottomSepartorView, bottomHStackView, loadingIndicatorView)
        bottomHStackView.addArrangedSubviews(locationButton, pageController, listButton)
        
        scrollView.addSubviews(topLoadingIndicatorView, scrollContentView)
    }
    
    func setConstraints() {
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        topLoadingIndicatorView.snp.makeConstraints {
            $0.width.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
            $0.bottom.equalTo(scrollView.snp.top)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(bottomSepartorView.snp.top)
        }
        
        scrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bottomSepartorView.snp.makeConstraints {
            $0.bottom.equalTo(bottomHStackView.snp.top)
            $0.width.horizontalEdges.equalToSuperview()
            $0.height.equalTo(0.2)
        }
        
        bottomHStackView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        pageController.snp.makeConstraints {
            $0.centerX.equalToSuperview()
        }
        
        locationButton.snp.makeConstraints {
            $0.width.height.equalTo(44)
        }
        
        listButton.snp.makeConstraints {
            $0.width.height.equalTo(44)
        }
        
        loadingIndicatorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bindUIEvents() {
        
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
                self.applyGradientBackground(time: self.weatherInfoList[page].currentTime)
                
                // 페이징 후 페이지 rive 재생
                backgroundViewList[page].riveViewModel.play()
            })
            .bind(to: pageController.rx.currentPage)
            .disposed(by: disposeBag)
        
        // 페이징이 되었을 시 동작 (페이지 컨트롤 클릭 시 대응)
        // 기본적으로 페이지 컨트롤 클릭 시 페이지 값이 변경되어 .valueChaned로 구현
        pageController.rx.controlEvent(.valueChanged)
            .map { [weak self] _ -> Int in
                guard let self else { return 0 }
                let currentPage = self.pageController.currentPage
                return currentPage
            }
            .subscribe(onNext: { [weak self] currentPage in
                guard let self else { return }
                // 페이징 후 스크롤 상단, 추후 메인 뷰 리팩토링 하면 스와이프 시에도 아마 적용 가능
                scrollView.scrollsToTop = true
                // 이전 페이지 정지, 현재 페이지 재생
                backgroundViewList[previousPage].riveViewModel.pause()
                backgroundViewList[currentPage].riveViewModel.play()
                
                let offsetX = Int(self.scrollView.frame.width) * currentPage
                self.scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
                self.applyGradientBackground(time: self.weatherInfoList[currentPage].currentTime)
                
                // 이전 페이지 업데이트
                self.previousPage = currentPage
            })
            .disposed(by: disposeBag)
        
        scrollView.rx.contentOffset
            .skip(10)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { owner, offset in
                if offset.y < -60 && !owner.scrollView.isDragging {
                    
                    UIView.animate(withDuration: 0.2) {
                        owner.scrollView.contentInset.top = 50
                    }
                    owner.topLoadingIndicatorView.play()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        UIView.animate(withDuration: 0.2) {
                            owner.scrollView.contentInset.top = 0
                        }
                        owner.topLoadingIndicatorView.pause()
                    })
                }
                
            }.disposed(by: disposeBag)
        
        // MARK: - Test
        // 테스트로 왼쪽 하단 위치 버튼 클릭 시 날씨 추가
        locationButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let mockWeather = WeatherInfo(address: "지역1", temperature: "15", skyInfo: "비", maxTemp: "16", minTemp: "14", rive: "Rainy", currentTime: 0.3)
                self.weatherInfoList.append(mockWeather)
                self.reloadUI(with: mockWeather)
            })
            .disposed(by: disposeBag)
        
        listButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let mockWeather = WeatherInfo(address: "지역2", temperature: "20", skyInfo: "천둥", maxTemp: "18", minTemp: "14", rive: "Thunderbolt", currentTime: 0.5)
                self.weatherInfoList.append(mockWeather)
                self.reloadUI(with: mockWeather)
            })
            .disposed(by: disposeBag)
    }
    
    func bindViewModel() {
        viewModel.action.onNext(.getCurrentWeather)
        
        viewModel.state.currentWeather
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (weather) in
                guard let self else { return }
                self.weatherInfoList.append(weather)
                self.reloadUI(with: weather)
                // 로딩 인디케이터 정지
                self.loadingIndicatorView.stopAnimating()
            }).disposed(by: disposeBag)
    }
    
    /// 초기 내장된 backgroundViews 생성 (향후 CoreData 로드 시 사용, 현재 비활성화)
    func setInitalBackgroundViews() {
        
        if !backgroundViewList.isEmpty {
            for (index, weather) in weatherInfoList.enumerated() {
                // Background View 추가
                _ = setBackgroundView(index: index, weather: weather)
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
        dimView.backgroundColor = .black.withAlphaComponent(normalizeAndClamp(time, valueMin: 0.0, valueMax: 0.5, targetMin: 0.0, targetMax: 0.5))
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
    
    func reloadUI(with weather: WeatherInfo) {
        let index = weatherInfoList.count - 1
        
        if index == 0 {
            pageController.alpha = 0
        } else {
            pageController.alpha = 1
        }
        
        // pageController 업데이트
        pageController.numberOfPages = weatherInfoList.count
        
        // Background View 추가
        let backgroundView = setBackgroundView(index: index, weather: weather)
        
        // 첫 번째 뷰일 경우 재생 및 배경 적용
        if index == 0 {
            backgroundView.riveViewModel.play()
            applyGradientBackground(time: weather.currentTime)
        }
    }
    
    // BackgroundView 추가
    private func setBackgroundView(index: Int, weather: WeatherInfo) -> BackgroundTopInfoView {
        /// containerView = backgroundView + mainView
        let containerView = UIView()
        let backgroundView = BackgroundTopInfoView(frame: .zero, weatherInfo: weather)
        let bottomInfoView = BottomInfoView()
        
        backgroundViewList.append(backgroundView)
        
        scrollContentView.addSubview(containerView)
        containerView.addSubviews(backgroundView, bottomInfoView)
        
        containerView.snp.makeConstraints {
            $0.top.bottom.equalTo(scrollContentView)
            $0.width.equalTo(view.snp.width)
            $0.leading.equalToSuperview().offset(CGFloat(index) * UIScreen.main.bounds.width)
        }
        
        backgroundView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(UIScreen.main.bounds.height).multipliedBy(0.6)
        }
        
        bottomInfoView.snp.makeConstraints {
            $0.top.equalTo(backgroundView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(view.snp.height)
        }
        
        // scrollContentView 제약 재설정
        scrollContentView.snp.remakeConstraints {
            $0.top.equalToSuperview()
            $0.edges.equalToSuperview()
            $0.width.equalTo(view.snp.width).multipliedBy(CGFloat(weatherInfoList.count))
            $0.height.equalTo(view.snp.height).multipliedBy(2.8)
        }
        
        // 하단 콜렉션뷰 데이터 설정
        //setRxDataSource(mainView: mainView)
        
        return backgroundView
    }
}

// MARK: - UICollectionViewDelegate
//extension BackgroundViewController: UICollectionViewDelegate {
//    func setRxDataSource(mainView: MainView) {
//        // Delegate 연결
//        mainView.collectionView.rx.setDelegate(self)
//            .disposed(by: disposeBag)
//        
//        // 예시 데이터(Mock)
//        let sections = Observable.just([
//            MainSection(items: [
//                .hourly(HourlyModel(hour: "Now", temperature: "20'C", weatherInfo: "sun.min")),
//                .hourly(HourlyModel(hour: "10시", temperature: "21'C", weatherInfo: "sun.horizon.fill")),
//                .hourly(HourlyModel(hour: "11시", temperature: "22'C", weatherInfo: "sun.haze.fill")),
//                .hourly(HourlyModel(hour: "12시", temperature: "23'C", weatherInfo: "sun.rain.fill")),
//                .hourly(HourlyModel(hour: "13시", temperature: "24'C", weatherInfo: "sun.snow.fill")),
//                .hourly(HourlyModel(hour: "14시", temperature: "25'C", weatherInfo: "cloud.drizzle.fill")),
//                .hourly(HourlyModel(hour: "15시", temperature: "26'C", weatherInfo: "cloud.bolt.rain.fill")),
//                .hourly(HourlyModel(hour: "16시", temperature: "27'C", weatherInfo: "sun.max")),
//                .hourly(HourlyModel(hour: "17시", temperature: "28'C", weatherInfo: "sun.min"))
//            ]),
//            MainSection(items: [
//                .daily(DailyModel(day: "오늘", high: "35", low: "11", weatherInfo: "sun.min")),
//                .daily(DailyModel(day: "화", high: "35", low: "30", weatherInfo: "sun.min")),
//                .daily(DailyModel(day: "수", high: "32", low: "27", weatherInfo: "sun.min")),
//                .daily(DailyModel(day: "목", high: "29", low: "24", weatherInfo: "sun.min")),
//                .daily(DailyModel(day: "금", high: "24", low: "19", weatherInfo: "sun.min")),
//                .daily(DailyModel(day: "토", high: "19", low: "14", weatherInfo: "sun.min")),
//                .daily(DailyModel(day: "일", high: "16", low: "11", weatherInfo: "sun.min"))
//            ]),
//            MainSection(items: [
//                .detail(DetailModel(title: "자외선지수", value: "1", weatherInfo: "sun.min")),
//                .detail(DetailModel(title: "자외선지수", value: "4", weatherInfo: "sun.min")),
//                .detail(DetailModel(title: "자외선지수", value: "6", weatherInfo: "sun.min")),
//                .detail(DetailModel(title: "자외선지수", value: "10", weatherInfo: "sun.min")),
//                .detail(DetailModel(title: "자외선지수", value: "11", weatherInfo: "sun.min")),
//                .detail(DetailModel(title: "자외선지수", value: "15", weatherInfo: "sun.min")),
//                .detail(DetailModel(title: "일출/일몰", value: "05:20/19:45", weatherInfo: "sun.min")),
//                .detail(DetailModel(title: "바람", value: "3m/s NW", weatherInfo: "sun.min")),
//                .detail(DetailModel(title: "강수량", value: "5mm", weatherInfo: "sun.min")),
//                .detail(DetailModel(title: "체감기온", value: "20℃", weatherInfo: "sun.min")),
//                .detail(DetailModel(title: "습도", value: "70%", weatherInfo: "sun.min"))
//            ])
//        ])
//        
//        // RxDataSources 바인딩
//        sections
//            .bind(to: mainView.collectionView.rx.items(dataSource: dataSource))
//            .disposed(by: disposeBag)
//    }
//}
