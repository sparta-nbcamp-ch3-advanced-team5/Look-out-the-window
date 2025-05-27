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
import RxCocoa
import CoreLocation

protocol PageChange: AnyObject {
    func scrollToTop()
}

final class WeatherDetailViewController: UIViewController {
    
    private let viewModel: WeatherDetailViewModel
    private let disposeBag = DisposeBag()
    private var previousPage = 0
    private var weatherInfoList = [CurrentWeather]()
    private var contentViewWidthConstraint: Constraint?
    
    var currentPage: Int
    weak var pageChangeDelegate: PageChange?
    
    private lazy var locationManager = CLLocationManager()
    
    // MARK: - UI Components
    /// 밝기관련 뷰 시간에 따라 어두워짐.
    private let dimView = UIView()
    /// 배경 Gradient
    private let gradientLayer = CAGradientLayer()
    
    private lazy var mainLoadingIndicator = MainLoadingIndicator()
    
    private lazy var weatherDetailViewList = [WeatherDetailScrollView]()
    
    /// 네트워크 데이터 바인딩용 Relay
    private let sectionsRelay = BehaviorRelay<[MainSection]>(value: [])
    
    private lazy var horizontalScrollView = UIScrollView().then {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let horizontalScrollContentView = UIView()
    
    private lazy var bottomSepartorView = UIView().then {
        $0.backgroundColor = .secondaryLabel
        $0.isHidden = true
    }
    
    private lazy var bottomHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.isHidden = true
    }
    
    private lazy var locationButton = UIButton().then {
        $0.setImage(UIImage(systemName: "location.fill", withConfiguration: nil), for: .normal)
        $0.tintColor = .label
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    private lazy var listButton = UIButton().then {
        $0.setImage(UIImage(systemName: "list.bullet", withConfiguration: nil), for: .normal)
        $0.tintColor = .label
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    private lazy var pageController = UIPageControl().then {
        $0.numberOfPages = viewModel.weatherInfoList.count
        $0.currentPage = 0
        $0.currentPageIndicatorTintColor = .white
        $0.pageIndicatorTintColor = .systemGray
    }
    
    // MARK: - Initializers
    init(viewModel: WeatherDetailViewModel, currentPage: Int) {
        self.viewModel = viewModel
        self.currentPage = currentPage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 코어데이터 파일 확인 위해 경로 print
        if let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            print("Documents Directory: \(documentsDirectoryURL)")
        }
        
        // CLLocationManagerDelegate 프로토콜 연결
        locationManager.delegate = self
        
        navigationItem.hidesBackButton = true
        
        bindViewModel()
        setupUI()
        bindUIEvents()
    }
}

// MARK: - Setting Methods
private extension WeatherDetailViewController {
    func setupUI() {
        setViewHiearchy()
        setConstraints()
        setInitalBackgroundViews(currentPage: currentPage)
    }
    
    //    func setAppearance() {
    //        // 리스트의 초기값으로 첫 화면 설정
    //        if !weatherInfoList.isEmpty {
    //            applyGradientBackground(time: Double(weatherInfoList[0].currentTime))
    //        }
    //    }
    
    func setViewHiearchy() {
        view.addSubviews(mainLoadingIndicator, dimView, horizontalScrollView, bottomSepartorView, bottomHStackView)
        bottomHStackView.addArrangedSubviews(locationButton, pageController, listButton)
        
        horizontalScrollView.addSubview(horizontalScrollContentView)
    }
    
    func setConstraints() {
        
        mainLoadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(50)
        }
        
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        horizontalScrollView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(bottomSepartorView.snp.top)
        }
        
        horizontalScrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
            self.contentViewWidthConstraint = $0.width.equalTo(view.snp.width).multipliedBy(CGFloat(weatherInfoList.count)).constraint
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
    }
    
    func bindUIEvents() {
        
        // 스크롤의 감속이 끝났을 때 페이징
        horizontalScrollView.rx.didEndDecelerating
            .map { [weak self] _ -> Int in
                guard let self else { return 0 }
                let currentPage = self.pageController.currentPage
                // scrollView 내부 콘첸트가 수평으로 얼마나 스크롤 됐는지 / scrollView가 화면에 차지하는 너비
                let page = Int(round(horizontalScrollView.contentOffset.x / horizontalScrollView.frame.width))
                // 페이징 직전 페이지 rive 중지
                weatherDetailViewList[currentPage].backgroundTopInfoView.riveViewModel.pause()
                return page
            }
            .do(onNext: { [weak self] page in
                guard let self else { return }
                self.applyGradientBackground(time: Double(self.weatherInfoList[page].currentTime))
                
                // 페이징 후 페이지 rive 재생
                weatherDetailViewList[page].backgroundTopInfoView.riveViewModel.play()
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
                handlePageChanged(to: currentPage)
            })
            .disposed(by: disposeBag)
        
        // 첫번째 페이지 이동, 권환 허용
        locationButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.currentPage = 0
                self.pageController.currentPage = 0
                handlePageChanged(to: 0)
            })
            .disposed(by: disposeBag)
        
        // 리스트 페이지로 이동
        listButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                navigationController?.popViewController(animated: false)
            })
            .disposed(by: disposeBag)
    }
    
    func bindViewModel() {
        viewModel.action.onNext(.getCurrentWeather)
        
        // 초기 설정값 불러오기
        viewModel.state.currentWeather
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (weather) in
                guard let self else { return }
                self.weatherInfoList.append(weather)
                // UI 생성
                self.reloadUI(with: weather)
                // 로딩 인디케이터 정지
                mainLoadingIndicator.riveViewModel.pause()
                // 로딩 정지 후 hidden 변경
                mainLoadingIndicator.isHidden = true
                self.bottomHStackView.isHidden = false
                self.bottomSepartorView.isHidden = false
            }).disposed(by: disposeBag)
    }
    
    /// 초기 내장된 backgroundViews 생성 (향후 CoreData 로드 시 사용, 현재 비활성화)
    func setInitalBackgroundViews(currentPage: Int) {
        
        if !weatherDetailViewList.isEmpty {
            for (index, weather) in weatherInfoList.enumerated() {
                // Background View 추가
                _ = setBackgroundView(index: index, weather: weather)
            }
            
            if let lastBackgroundView = weatherDetailViewList.last {
                lastBackgroundView.snp.makeConstraints {
                    $0.trailing.equalTo(view.snp.trailing)
                }
            }
            
            pageController.currentPage = currentPage
            
            // 첫번째 뷰 rive play
            weatherDetailViewList[currentPage].backgroundTopInfoView.riveViewModel.play()
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
    
    func reloadUI(with weather: CurrentWeather) {
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
            applyGradientBackground(time: Double(weather.currentTime))
        }
    }
    
    // BackgroundView 추가
    func setBackgroundView(index: Int, weather: CurrentWeather) -> BackgroundTopInfoView {
        
        let weatherDetailScrollView = WeatherDetailScrollView(frame: .zero, weather: weather)
        weatherDetailScrollView.pullToRefreshDelegate = self
        weatherDetailViewList.append(weatherDetailScrollView)
        
        horizontalScrollContentView.addSubview(weatherDetailScrollView)
        
        weatherDetailScrollView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.height.equalToSuperview()
            $0.width.equalTo(view.snp.width)
            $0.leading.equalToSuperview().offset(CGFloat(index) * UIScreen.main.bounds.width)
        }
        
        self.contentViewWidthConstraint?.update(
            offset: UIScreen.main.bounds.width * CGFloat(weatherInfoList.count)
        )
        
        return weatherDetailScrollView.backgroundTopInfoView
    }
    
    // 페이징 후 스크롤 이동 및 배경 처리 등
    func handlePageChanged(to currentPage: Int) {
        // 페이징 후 스크롤 상단
        pageChangeDelegate?.scrollToTop()
        // 이전 페이지 정지, 현재 페이지 재생
        weatherDetailViewList[previousPage].backgroundTopInfoView.riveViewModel.pause()
        weatherDetailViewList[currentPage].backgroundTopInfoView.riveViewModel.play()
        
        let offsetX = Int(self.horizontalScrollView.frame.width) * currentPage
        self.horizontalScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        self.applyGradientBackground(time: Double(self.weatherInfoList[currentPage].currentTime))
        
        // 이전 페이지 업데이트
        self.previousPage = currentPage
        // 현재 페이지 업데이트
        self.currentPage = currentPage + 1
        print(self.currentPage)
    }
    
    // 사용자에게 권한 요청을 하기 위해 iOS 위치 서비스 활성화 여부 체크
    func checkDeviceLocationAuthorization() {
        DispatchQueue.global().async {
            
            if CLLocationManager.locationServicesEnabled() {
                
                let authorization: CLAuthorizationStatus
                
                if #available(iOS 14.0, *) {
                    authorization = self.locationManager.authorizationStatus
                } else {
                    authorization = CLLocationManager.authorizationStatus()
                }
                DispatchQueue.main.async {
                    self.checkCurrentLocationAuthorization(status: authorization)
                }
            } else {
                print("위치 서비스 꺼져 있어서, 위치 권한 요청을 할 수 없습니다.")
                self.showLocationSettingAlert()
            }
        }
    }
    
    // 사용자 위치 권한 상태 확인 -> 권한 요청
    func checkCurrentLocationAuthorization(status: CLAuthorizationStatus) {
        let status = locationManager.authorizationStatus
        
        switch status {
            
        case .notDetermined:
            print("notDetermined - 이 권한에서만 권한 문구를 띄울 수 있음")
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization() // info.plist에서 허용한 권한관 동일
        case .denied:
            print("denied - 설정으로 이동하는 Alert 띄우기")
            showLocationSettingAlert()
        case .authorizedWhenInUse:
            print("authorizationWhenInUse - 정상 로직 실행하면 됨.")
            locationManager.startUpdatingLocation() // GPS 기능 정상 작동
        default:
            print("default - 오류 발생")
        }
    }
    
    // 설정 이동 Alert
    func showLocationSettingAlert() {
        let alert = UIAlertController(title: "위치 정보 이용",
                                      message: "위치 서비스를 사용할 수 없습니다. 기기의 '설정 > 개인정보 보호'에서 위치 서비스를 켜주세요", preferredStyle: .alert)
        let goSetting = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let setting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(setting)
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(goSetting)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}

extension WeatherDetailViewController: PullToRefresh {
    
    // pullToRefresh 시 네트워크 재요청 및 코어데이터에 저장
    func updateAndSave() {
        viewModel.action.onNext(.pullToRefresh)
    }
}


extension WeatherDetailViewController: CLLocationManagerDelegate {
    // 위치 권한 허용 O
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    // 위치 권한 허용 X
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {

    }
    
    // iOS 14+
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkDeviceLocationAuthorization()
    }
    
    // iOS 14 미만
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkDeviceLocationAuthorization()
    }
}
