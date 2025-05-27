//
//  RegisterViewController.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/26/25.
//

import UIKit

import SnapKit
import Then
import RxSwift
import RxDataSources
import RxRelay

final class RegisterViewController: UIViewController {
    
    let mock = WeatherInfo(address: "지역1", temperature: "15", skyInfo: "비", maxTemp: "16", minTemp: "14", rive: "Rainy", currentTime: 0.3)
    private let disposeBag = DisposeBag()
    private let viewModel: RegisterViewModel
    
    private let detailView = WeatherDetailCollectionView()
    private var topInfoView: BackgroundTopInfoView
    
    private lazy var verticalScrollView = UIScrollView().then {
        $0.isPagingEnabled = false
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .mainBackground
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        }
    }
    
    
    private let addButton = UIButton().then {
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
    }
    private let cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
    }
    
    init(viewModel: RegisterViewModel, isCurrLocation: Bool) {
        self.viewModel = viewModel
        self.topInfoView = BackgroundTopInfoView(frame: .zero, weatherInfo: mock)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    func bind() {
        viewModel.action.onNext(.viewDidLoad)
        
        viewModel.state.currentWeather
            .compactMap{ $0 }
            .bind(to: detailView.rx.items(dataSource: detailView.detailDataSource))
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.viewModel.action.onNext(.plusButtonTapped)
            }.disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
    }
    func updateCollectionViewHeight() {
        detailView.collectionViewLayout.invalidateLayout()
        detailView.layoutIfNeeded()
        let contentHeight = detailView.collectionViewLayout.collectionViewContentSize.height
        detailView.snp.updateConstraints {
            $0.width.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(topInfoView.riveView.snp.bottom)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(contentHeight)
        }
    }
}

private extension RegisterViewController {
    func setupUI() {
        view.backgroundColor = .mainBackground
        setNavigationBar()
        addViews()
        configureLayout()
        detailView.isScrollEnabled = false
    }
    
    func setNavigationBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
    }
    
    func addViews() {
        view.addSubview(verticalScrollView)
        verticalScrollView.addSubviews(topInfoView, detailView)
    }
    
    func configureLayout() {
        verticalScrollView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.top.bottom.equalToSuperview()
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        topInfoView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.6)
        }
        detailView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(topInfoView.riveView.snp.bottom)
            $0.height.equalToSuperview().multipliedBy(2.8)
            $0.bottom.equalToSuperview()
        }
    }
}

