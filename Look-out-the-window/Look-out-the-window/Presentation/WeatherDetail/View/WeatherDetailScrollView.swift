//
//  WeatherDetailScrollView.swift
//  Look-out-the-window
//
//  Created by 정근호 on 5/26/25.
//


import UIKit

import SnapKit
import Then
import RxSwift
import RxDataSources
import RxRelay

protocol PullToRefresh: AnyObject {
    func updateAndSave()
}

final class WeatherDetailScrollView: UIView {
    
    private let disposeBag = DisposeBag()
    private let sectionsRelay = BehaviorRelay<[MainSection]>(value: [])
    
    private var weather: CurrentWeather
    private var totalMinTemp = 0
    private var totalMaxTemp = 0
    private var isPulling = false
    
    weak var pullToRefreshDelegate: PullToRefresh?
    
    // MARK: - UI Components
    private lazy var verticalScrollView = UIScrollView().then {
        $0.isPagingEnabled = false
        $0.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        }
    }
    private lazy var verticalScrollContentView = UIView()
    var backgroundTopInfoView: BackgroundTopInfoView
    private lazy var weatherDetailCollectionView = WeatherDetailCollectionView().then {
        $0.clipsToBounds = true
    }
    private lazy var topLoadingIndicatorView = LoadingIndicatorView()
    
    // verticalScrollContentView의 높이 제약 조건 저장
    private var verticalScrollContentViewHeightConstraint: Constraint?
    
    
    init(frame: CGRect, weather: CurrentWeather) {
        self.weather = weather
        self.backgroundTopInfoView = BackgroundTopInfoView(frame: .zero)
        self.backgroundTopInfoView.configure(model: weather)
        super.init(frame: frame)
        
        bindDataSource()
        bindUIEvents()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // WeatherDetailViewController 에서 사용
    func updateWeather(newWeather: CurrentWeather) {
        self.weather = newWeather
        self.configureMainSectionsAndHeight()
    }
}

private extension WeatherDetailScrollView {
    func setupUI() {
        topLoadingIndicatorView.isHidden = true
        weatherDetailCollectionView.isScrollEnabled = false
        configureMainSectionsAndHeight()
        setViewHierarchy()
        setConstraints()
        setRxDataSource(weatherDetailCollectionView: weatherDetailCollectionView)
        layoutIfNeeded()
    }
    
    func setViewHierarchy() {
        addSubview(verticalScrollView)
        verticalScrollView.addSubviews(topLoadingIndicatorView, verticalScrollContentView)
        verticalScrollContentView.addSubviews(backgroundTopInfoView, weatherDetailCollectionView)
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
            // 초기 높이 제약 조건 저장
            self.verticalScrollContentViewHeightConstraint = $0.height.equalTo(1000).constraint // 초기값
        }
        
        backgroundTopInfoView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.6)
        }
        
        weatherDetailCollectionView.snp.makeConstraints {
            $0.top.equalTo(backgroundTopInfoView.loadingRiveView.snp.bottom)
            $0.bottom.equalToSuperview()
            $0.directionalHorizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    func bindDataSource() {
        sectionsRelay
            .bind(to: weatherDetailCollectionView.rx.items(dataSource: weatherDetailCollectionView.detailDataSource))
            .disposed(by: disposeBag)
    }
    
    func bindUIEvents() {
        verticalScrollView.rx.contentOffset
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { owner, offset in
                if offset.y < -60 && !owner.verticalScrollView.isDragging {
                    // 스와이프 중인지 체크, isPulling이 false일 때 작동
                    guard !owner.isPulling else { return }
                    owner.isPulling = true
                    
                    UIView.animate(withDuration: 0.2) {
                        owner.verticalScrollView.contentInset.top = 150
                    }
                    owner.topLoadingIndicatorView.isHidden = false
                    owner.topLoadingIndicatorView.play()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        UIView.animate(withDuration: 0.2) {
                            owner.verticalScrollView.contentInset.top = 0
                        }
                        owner.topLoadingIndicatorView.pause()
                        owner.topLoadingIndicatorView.isHidden = true
                        owner.pullToRefreshDelegate?.updateAndSave()
                        owner.isPulling = false
                    }
                }
            }
            .disposed(by: disposeBag)
        
        // 컬렉션 뷰의 contentSize를 관찰
        weatherDetailCollectionView.rx.observe(CGSize.self, "contentSize")
            .compactMap { $0 } // nil 제거
            .distinctUntilChanged() // 높이가 변경될 때만 반응
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] contentSize in
                guard let self else { return }
                let newHeight = self.backgroundTopInfoView.frame.height + contentSize.height + CGFloat(170)
                self.verticalScrollContentViewHeightConstraint?.update(offset: newHeight)
                self.layoutIfNeeded() // 제약 조건 업데이트 후 레이아웃 즉시 반영
            })
            .disposed(by: disposeBag)
    }
    
    func configureMainSectionsAndHeight() {
        let sections = weather.toMainSections()
        sectionsRelay.accept(sections)
    }
}

// MARK: - UICollectionViewDelegate
extension WeatherDetailScrollView: UICollectionViewDelegate {
    func setRxDataSource(weatherDetailCollectionView: WeatherDetailCollectionView) {
        // Delegate 연결
        weatherDetailCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
}

extension WeatherDetailScrollView: PageChange {
    func scrollToTop() {
        verticalScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}
