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

/// 지역 리스트 ViewController
final class RegionWeatherListViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    private let viewModel = RegionWeatherListViewModel()
    private let disposeBag = DisposeBag()
    
    private let dataSource = RxCollectionViewSectionedAnimatedDataSource<RegionWeatherListSection> { dataSource, collectionView, indexPath, item in
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RegionWeatherCell.identifier, for: indexPath) as? RegionWeatherCell else { return UICollectionViewCell() }
        cell.configure(model: item)
        return cell
    }
    
    // MARK: - UI Components
    
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
        
        setupUI()
        configureCollectionView()
    }
}

// MARK: - UI Methods

private extension RegionWeatherListViewController {
    func setupUI() {
        setAppearance()
        setDelegates()
        setViewHierarchy()
        setConstraints()
        bind()
    }
    
    func setAppearance() {
        self.view.backgroundColor = .mainBackground
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.placeholder = "도시 또는 우편번호 검색"
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = true
    }
    
    func setDelegates() {
        searchController.searchBar.delegate = searchResultVC
        
        searchResultVC.delegate = self
    }
    
    func setViewHierarchy() {
        self.view.addSubview(regionListView)
    }
    
    func setConstraints() {
        regionListView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind() {
        // ViewModel ➡️ ViewController
        viewModel.state.regionWeatherListSectionRelay
            .asDriver(onErrorJustReturn: [])
            .drive(regionListView.getCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        
        // ViewController ➡️ ViewModel
        viewModel.action.onNext(.viewDidLoad)
        
        
        // View ➡️ ViewController
//        regionListView.getCollectionView.rx.modelSelected(CurrentWeather.self)
//            .asDriver()
//            .drive(with: self) { owner, model in
//                // TODO: Main 화면 present
//                dump(model)
//                os_log(.debug, log: owner.log, "Main 화면 present")
//            }.disposed(by: disposeBag)
        
        // 현재 index값 안받아와짐
        Observable.zip(
            regionListView.getCollectionView.rx.modelSelected(CurrentWeather.self),
            regionListView.getCollectionView.rx.itemSelected
        )
        .asDriver(onErrorDriveWith: .empty())
        .drive(with: self) { owner, tuple in
            let (model, indexPath) = tuple
            
            print("선택된 indexPath.row: \(indexPath.row)")
            
            let detailVC = WeatherDetailViewController(
                viewModel: WeatherDetailViewModel(),
                currentPage: indexPath.row // 인덱스 전달
            )
            owner.navigationController?.pushViewController(detailVC, animated: false)
            
            dump(model)
            os_log(.debug, log: owner.log, "Main 화면 present")
        }
        .disposed(by: disposeBag)
    }
}

// MARK: - UICollectionView Methods

private extension RegionWeatherListViewController {
    func configureCollectionView() {
        regionListView.getCollectionView.register(RegionWeatherCell.self, forCellWithReuseIdentifier: RegionWeatherCell.identifier)
    }
}

// MARK: - SearchResultViewControllerDelegate

extension RegionWeatherListViewController: SearchResultViewControllerDelegate {
    func cellDidTapped() {
        searchController.searchBar.resignFirstResponder()
    }
}
