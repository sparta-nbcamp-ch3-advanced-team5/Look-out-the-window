//
//  RegionWeatherListViewController.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/21/25.
//

import UIKit
import OSLog

import RxCocoa
import RxDataSources
import RxSwift
import SnapKit
import RiveRuntime

/// 지역 리스트 ViewController
final class RegionWeatherListViewController: UIViewController {

    // MARK: - Properties

    private lazy var log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))

    public let viewModel = RegionWeatherListViewModel()
    private let disposeBag = DisposeBag()
    private var initialAppLoaded = false
    //init 시점으로 바꾸기

    private let dataSource = RxTableViewSectionedAnimatedDataSource<RegionWeatherListSection>(animationConfiguration: AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .automatic, deleteAnimation: .fade)) { dataSource, tableView, indexPath, item in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RegionWeatherCell.identifier, for: indexPath) as? RegionWeatherCell else { return UITableViewCell() }
        cell.configure(model: item)
        return cell
    }
    
    private let mainLoadingIndicator = MainLoadingIndicator()
    
    // MARK: - UI Components
    private let dimView = UIView()

    private let gradientLayer = CAGradientLayer()

    // TODO: 아래로 당겨서 업데이트
    private let searchController: UISearchController
    private let searchResultVC = SearchResultViewController()

    private let regionListView = RegionWeatherListView()

    // MARK: - Initializer

    init() {
        searchController = UISearchController(searchResultsController: searchResultVC)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mainLoadingIndicator)
        mainLoadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(50)
        }
        view.bringSubviewToFront(mainLoadingIndicator)
        mainLoadingIndicator.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.deferredSetup()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.action.onNext(.viewDidLoad)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.mainLoadingIndicator.riveViewModel.pause()
            self.mainLoadingIndicator.isHidden = true
        }
    }
}

// MARK: - UI Methods

private extension RegionWeatherListViewController {
    
    func deferredSetup() {
        self.configureTableView()
        self.configureDataSource()
        self.setupUI()
    }
    
    func setupUI() {
        setAppearance()
        setDelegates()
        setViewHierarchy()
        
        mainLoadingIndicator.isHidden = false
        view.addSubview(mainLoadingIndicator)
        view.bringSubviewToFront(mainLoadingIndicator)
        mainLoadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(50)
        }
        
        setConstraints()
        bind()
        applyGradientBackground()
    }

    func setAppearance() {
        self.view.backgroundColor = .mainBackground
        
        self.navigationItem.title = "날씨"
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController.searchBar.placeholder = "도시 또는 우편번호 검색"
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = true
    }

    func setDelegates() {
        searchController.searchBar.delegate = searchResultVC

        searchResultVC.delegate = self
    }

    func setViewHierarchy() {
        self.view.addSubviews(dimView, regionListView)
    }

    func setConstraints() {
        regionListView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    /// Gradient, 밝기 설정
    func applyGradientBackground() {
        gradientLayer.colors = [ UIColor.mainBackground1.cgColor, UIColor.secondaryBackground.cgColor ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        dimView.backgroundColor = .black.withAlphaComponent(0.3)
        // 배경이니 제일 하단에 위치하도록
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func bind() {
        // ViewModel ➡️ ViewController
        viewModel.state.regionWeatherListSectionRelay
            .asDriver(onErrorJustReturn: [])
            .drive(regionListView.getTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        
        // ViewController ➡️ ViewModel
        regionListView.getTableView.rx.itemDeleted
            .subscribe(with: self) { owner, indexPath in
                owner.viewModel.action.onNext(.itemDeleted(indexPath: indexPath))
            } onError: { owner, error in
                os_log(.error, log: owner.log, "itemDeleted: \(error.localizedDescription)")
            }.disposed(by: disposeBag)

        Observable<Int>.interval(.seconds(900), scheduler: MainScheduler.asyncInstance)  // 15분 간격
            .subscribe(with: self) { owner, _ in
                owner.viewModel.action.onNext(.update)
            }.disposed(by: disposeBag)
        
//        viewModel.action.onNext(.viewDidLoad)


        // View ➡️ ViewController
        regionListView.getTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

//        regionListView.getTableView.rx.modelSelected(CurrentWeather.self)
//            .asDriver()
//            .drive(with: self) { owner, model in
//                // TODO: Main 화면 present
//                dump(model)
//
//                 주형: index 아이템 클릭시 주소 저장
//                UserDefaults.standard.set(model.address, forKey: "LastViewedWeatherAddress")
//                // CoreData에서 해당 주소 날씨 fetch → 상세화면 push
//                if let entity = CoreDataManager.shared.fetchWeather(for: model.address) {
//                    let viewModel = WeatherDetailViewModel(entity: entity)
//                    let detailVC = WeatherDetailViewController(viewModel: viewModel, currentPage: 0)
//                    owner.navigationController?.pushViewController(detailVC, animated: true)
//                }
//
//                os_log(.debug, log: owner.log, "Main 화면 present")
//            }.disposed(by: disposeBag)


        // MARK: - 근호님 코드
        regionListView.getTableView.rx.itemSelected
            .asDriver()
            .drive(with: self) { owner, indexPath in
                
                print("선택된 indexPath.row: \(indexPath.row)")
                
                let detailVC = WeatherDetailViewController(viewModel: owner.viewModel, currentPage: indexPath.row)
                owner.navigationController?.pushViewController(detailVC, animated: false)
                
                dump(indexPath)
                os_log(.debug, log: owner.log, "Main 화면 present")
            }.disposed(by: disposeBag)
    }
}

// MARK: - UITableView Methods

private extension RegionWeatherListViewController {
    func configureDataSource() {
        dataSource.canEditRowAtIndexPath = { dataSource, indexPath in
            do {
                if let model = try dataSource.model(at: indexPath) as? CurrentWeather,
                   model.isCurrLocation {
                    return false
                }
                return true
            } catch {
                os_log(.error, log: self.log, "canEditRowAtIndexPath: \(error.localizedDescription)")
                return false
            }
        }
    }
    
    func configureTableView() {
        regionListView.getTableView.register(RegionWeatherCell.self, forCellReuseIdentifier: RegionWeatherCell.identifier)
    }
}

extension RegionWeatherListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

// MARK: - SearchResultViewControllerDelegate

extension RegionWeatherListViewController: SearchResultViewControllerDelegate {
    func localSearchResultDidArrived(location: LocationModel) {
        let savedRegionList = viewModel.state.regionWeatherListSectionRelay.value[0].items
        let isSavedLocation = savedRegionList.filter({ $0.address == location.toAddress() }).isEmpty ? false : true
        let registerVC = RegisterViewController(viewModel: RegisterViewModel(address: location.toAddress(), lat: location.lat, lng: location.lng), isSavedLocation: isSavedLocation)
        registerVC.delegate = self
        let naviVC = UINavigationController(rootViewController: registerVC)
        self.present(naviVC, animated: true)
    }
}

// MARK: - RegisterViewControllerDelegate

extension RegionWeatherListViewController: RegisterViewControllerDelegate {
    func modalWillDismissed() {
        viewModel.action.onNext(.regionRegistered)
    }
}
