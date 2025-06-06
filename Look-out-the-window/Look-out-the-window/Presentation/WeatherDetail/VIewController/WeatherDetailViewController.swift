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

final class WeatherDetailViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    private let viewModel: RegionWeatherListViewModel
    private let disposeBag = DisposeBag()
    private var previousPage = 0
    private var weatherInfoList = [CurrentWeather]()
    private var contentViewWidthConstraint: Constraint?
    
    weak var pageChangeDelegate: PageChange?
    
    private lazy var locationManager = CLLocationManager()
    
    private var currentPage = 0
    
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
        $0.numberOfPages = 0
        $0.currentPage = 0
        $0.currentPageIndicatorTintColor = .white
        $0.pageIndicatorTintColor = .systemGray
    }
    
    // MARK: - Initializers
    init(viewModel: RegionWeatherListViewModel, currentPage: Int) {
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
    
        // UI, 이벤트, 바인딩 먼저
        setupUI()
        bindUIEvents()
        bindViewModel()
        
        // 로딩 인디케이터만 보여주기
        mainLoadingIndicator.isHidden = false
        view.addSubview(mainLoadingIndicator)
        view.bringSubviewToFront(mainLoadingIndicator)
        mainLoadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(50)
        }
        
        bottomHStackView.isHidden = true
        bottomSepartorView.isHidden = true
    }
}

// MARK: - Setting Methods
private extension WeatherDetailViewController {
    func setupUI() {
        setViewHiearchy()
        setConstraints()
        //        setInitalBackgroundViews(currentPage: currentPage)
    }
    
    //    func setAppearance() {
    //        // 리스트의 초기값으로 첫 화면 설정
    //        if !weatherInfoList.isEmpty {
    //            applyGradientBackground(time: Double(weatherInfoList[0].currentTime))
    //        }
    //    }
    
    func setViewHiearchy() {
        view.addSubviews(dimView, horizontalScrollView, bottomSepartorView, bottomHStackView)
        bottomHStackView.addArrangedSubviews(locationButton, pageController, listButton)
        
        horizontalScrollView.addSubview(horizontalScrollContentView)
    }
    
    func setConstraints() {
        
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
            $0.height.equalTo(0.3)
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
            .observe(on: MainScheduler.instance)
            .map { [weak self] _ -> Int in
                guard let self else { return 0 }
                // scrollView 내부 콘첸트가 수평으로 얼마나 스크롤 됐는지 / scrollView가 화면에 차지하는 너비
                let newPage = Int(round(horizontalScrollView.contentOffset.x / horizontalScrollView.frame.width))
                return newPage
            }
            .do(onNext: { [weak self] newPage in
                guard let self else { return }
                
                // 페이지가 변경 되었을 때만 조정
                if newPage != previousPage {
                    
                    // 이전 페이지 rive 중지
                    self.weatherDetailViewList[self.previousPage].backgroundTopInfoView.riveViewModel.pause()
                    
                    self.applyGradientBackground(time: Double(self.weatherInfoList[newPage].currentTime))
                    
                    handlePageChanged(to: newPage)
                    
                    // 페이징 후 페이지 rive 재생
                    weatherDetailViewList[newPage].backgroundTopInfoView.riveViewModel.play()
                }
            })
            .bind(to: pageController.rx.currentPage)
            .disposed(by: disposeBag)
        
        // 페이징이 되었을 시 동작 (페이지 컨트롤 클릭 시 대응)
        // 기본적으로 페이지 컨트롤 클릭 시 페이지 값이 변경되어 .valueChaned로 구현
        pageController.rx.controlEvent(.valueChanged)
            .observe(on: MainScheduler.instance)
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
                navigationController?.topViewController?.transitioningDelegate = self
                navigationController?.popViewController(animated: false)
            })
            .disposed(by: disposeBag)
    }
    
    func bindViewModel() {
        viewModel.action.onNext(.viewDidLoad)
        
        // 초기 설정값 불러오기
        viewModel.state.regionWeatherListSectionRelay
            .asDriver()
            .drive(with: self, onNext: { owner, weatherListSections in
                weatherListSections.forEach { section in
                    section.items.forEach { weather in
                        if !owner.weatherInfoList.contains(where: { $0.address == weather.address }) {
                            owner.weatherInfoList.append(weather)
                            
                            let index = owner.weatherInfoList.count - 1
                            
                            _ = owner.setBackgroundView(index: index, weather: weather)
                            self.applyGradientBackground(time: Double(self.weatherInfoList[index].currentMomentValue))
                        }
                    }
                }
                
                owner.pageController.numberOfPages = owner.weatherInfoList.count
                owner.pageController.currentPage = owner.currentPage
                
                let offsetX = Int(self.horizontalScrollView.frame.width) * (owner.currentPage)
                self.horizontalScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
                owner.weatherDetailViewList[owner.currentPage].backgroundTopInfoView.riveViewModel.play()
                
                // 로딩 인디케이터 멈추고 숨김
                owner.mainLoadingIndicator.riveViewModel.pause()
                owner.mainLoadingIndicator.isHidden = true
                
                // 메인 UI 보여주기
                owner.bottomHStackView.isHidden = false
                owner.bottomSepartorView.isHidden = false
            }).disposed(by: disposeBag)
    }
}

// MARK: - 뷰 관련 메서드
private extension WeatherDetailViewController {
    
    func reloadWeatherDetailView(with weather: CurrentWeather) {
        guard currentPage < weatherDetailViewList.count else { return }
        
        let weatherDetailView = weatherDetailViewList[currentPage]
        
        // 이 안에서 weather를 다시 넣고 UI 갱신
        weatherDetailView.updateWeather(newWeather: weather)
    }
    
    // BackgroundView 추가
    func setBackgroundView(index: Int, weather: CurrentWeather) -> BackgroundTopInfoView {
        
        let weatherDetailScrollView = WeatherDetailScrollView(frame: .zero, weather: weather)
        
        // 델리게이트 설정
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
    
    /// 페이징 후 스크롤 이동, 배경 처리, 레이아웃 조정
    func handlePageChanged(to currentPage: Int) {
        // 이전 페이지 정지, 현재 페이지 재생
        weatherDetailViewList[previousPage].backgroundTopInfoView.riveViewModel.pause()
        weatherDetailViewList[currentPage].backgroundTopInfoView.riveViewModel.play()
        
        self.pageChangeDelegate = weatherDetailViewList[currentPage]
        weatherDetailViewList[currentPage].scrollToTop()
        
        let offsetX = Int(self.horizontalScrollView.frame.width) * currentPage
        self.horizontalScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        self.applyGradientBackground(time: Double(self.weatherInfoList[currentPage].currentMomentValue))
        
        // 이전 페이지 업데이트
        self.previousPage = currentPage
        // 현재 페이지 업데이트
        self.currentPage = currentPage
        print("currentPage: \(self.currentPage)")
    }
    
    /// Gradient, 밝기 설정
    func applyGradientBackground(time: Double) {
        gradientLayer.colors = [ UIColor.mainBackground1.cgColor, UIColor.secondaryBackground.cgColor ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        dimView.backgroundColor = .black.withAlphaComponent(normalizeAndClamp(time, valueMin: 0.0, valueMax: 0.5, targetMin: 0.0, targetMax: 0.4))
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
}

// MARK: - PullToRefresh
extension WeatherDetailViewController: PullToRefresh {
    
    // pullToRefresh 시 네트워크 재요청 및 코어데이터에 저장
    func updateAndSave() {
        viewModel.action.onNext(.update)
    }
}

// MARK: - CLLocationManager 관련
extension WeatherDetailViewController: CLLocationManagerDelegate {
    
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

// MARK: -

