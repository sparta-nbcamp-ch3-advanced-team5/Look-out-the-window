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

final class WeatherDetailScrollView: UIView {
    
    private let disposeBag = DisposeBag()
    
    private var totalMinTemp = 0
    private var totalMaxTemp = 0
    
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
    private lazy var bottomInfoView = BottomInfoView()
    private lazy var topLoadingIndicatorView = LoadingIndicatorView()
    
    
    init(frame: CGRect, weather: CurrentWeather) {
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
    }

    func setViewHierarchy() {
        addSubview(verticalScrollView)
        verticalScrollView.addSubviews(topLoadingIndicatorView, verticalScrollContentView)
        verticalScrollContentView.addSubviews(backgroundView, bottomInfoView)
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
        
        bottomInfoView.snp.makeConstraints {
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
