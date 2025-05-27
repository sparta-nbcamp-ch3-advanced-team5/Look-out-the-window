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

/// 등록 화면을 담당하는 뷰 컨트롤러
/// 사용자의 현재 날씨 정보를 표시하고, 컬렉션 뷰로 날씨 세부 정보를 보여줌
final class RegisterViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: RegisterViewControllerDelegate?

    /// Rx 메모리 정리를 위한 DisposeBag
    private let disposeBag = DisposeBag()
    
    /// 비즈니스 로직 및 상태 관리를 담당하는 ViewModel
    private let viewModel: RegisterViewModel
    
    /// 날씨 정보를 표시하는 컬렉션 뷰
    private let detailView = WeatherDetailCollectionView()
    
    /// 상단 배경 뷰 (현재 날씨 정보 포함)
    private var topInfoView: BackgroundTopInfoView
    
    /// 전체 스크롤을 담당하는 UIScrollView
    private lazy var verticalScrollView = UIScrollView().then {
        $0.isPagingEnabled = false
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .mainBackground
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        }
    }
    
    /// 날씨 항목 추가 버튼
    private let addButton = UIButton().then {
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
    }

    /// 취소 버튼
    private let cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
    }

    // MARK: - Initializer

    /// 등록 화면 초기화
    /// - Parameters:
    ///   - viewModel: 연결할 ViewModel
    ///   - isCurrLocation: 이미 저장된 위치인지 판단에 따라 버튼 표시 여부 결정
    init(viewModel: RegisterViewModel, isSavedLocation: Bool) {
        self.viewModel = viewModel
        self.topInfoView = BackgroundTopInfoView()
        super.init(nibName: nil, bundle: nil)
        if isSavedLocation {
            addButton.isHidden = true
        }
    }

    /// Interface Builder를 통한 초기화는 지원하지 않음
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    // MARK: - Binding

    /// ViewModel과 UI를 바인딩
    func bind() {
        viewModel.action.onNext(.viewDidLoad)

        // 날씨 섹션 데이터를 컬렉션 뷰에 바인딩
        viewModel.state.weatherMainSections
            .compactMap { $0 }
            .bind(to: detailView.rx.items(dataSource: detailView.detailDataSource))
            .disposed(by: disposeBag)
        
        // 데이터 바인딩 후 컬렉션뷰 높이 계산 및 반영
        let contentHeightObservable = viewModel.state.weatherMainSections
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .flatMapLatest { owner, _ -> Observable<CGFloat> in
                return Observable<CGFloat>.create { [weak detailView = owner.detailView] observer in
                    DispatchQueue.main.async {
                        detailView?.layoutIfNeeded()
                        let height = detailView?.contentSize.height ?? 0
                        observer.onNext(height)
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            }

        // 계산된 높이를 반영
        contentHeightObservable
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(with: self) { owner, height in
                owner.updateCollectionViewHeight(height: height)
            }.disposed(by: disposeBag)
        
        // 현재 날씨 정보 바인딩
        viewModel.state.currentWeather
            .compactMap { $0 }
            .subscribe(with: self) { owner, weather in
                owner.topInfoView.configure(model: weather)
            }.disposed(by: disposeBag)
        
        // 플러스 버튼 탭 이벤트 처리
        addButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.viewModel.action.onNext(.plusButtonTapped)
                owner.delegate?.modalWillDismissed()
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
        
        // 취소 버튼 탭 이벤트 처리
        cancelButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }.disposed(by: disposeBag)
    }

    /// 컬렉션 뷰 높이 갱신
    /// - Parameter height: 계산된 콘텐츠 높이
    func updateCollectionViewHeight(height: CGFloat) {
        detailView.snp.updateConstraints {
            $0.height.equalTo(height + 40)
        }
    }
}

// MARK: - UI Setup

private extension RegisterViewController {

    /// 전체 UI 구성
    func setupUI() {
        view.backgroundColor = .mainBackground
        setNavigationBar()
        addViews()
        configureLayout()
        detailView.isScrollEnabled = false
    }

    /// 네비게이션 바 설정
    func setNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .mainBackground
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
    }

    /// 서브뷰 추가
    func addViews() {
        view.addSubview(verticalScrollView)
        verticalScrollView.addSubviews(topInfoView, detailView)
    }

    /// 오토레이아웃 구성 (SnapKit 사용)
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
            $0.top.equalTo(topInfoView.loadingRiveView.snp.bottom)
            $0.height.equalTo(1000) // 초기값
            $0.bottom.equalToSuperview()
        }
    }
}
