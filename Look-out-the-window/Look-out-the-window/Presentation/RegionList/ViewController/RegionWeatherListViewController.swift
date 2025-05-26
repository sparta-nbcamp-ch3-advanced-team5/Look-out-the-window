//
//  RegionWeatherListViewController.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/21/25.
//

import UIKit
import OSLog

import RxCocoa
import RxSwift
import SnapKit

/// 지역 리스트 ViewController
final class RegionWeatherListViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    private let viewModel = RegionWeatherListViewModel()
    private let disposeBag = DisposeBag()
    
    private let sectionInset: UIEdgeInsets = .init(top: 0, left: 20, bottom: 0, right: 20)
    private let itemSpacing: CGFloat = 30
    
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
        configureTableView()
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
        viewModel.state.regionWeatherList
            .asDriver(onErrorJustReturn: [])
            .drive(regionListView.getCollectionView.rx.items(cellIdentifier: RegionWeatherCell.identifier, cellType: RegionWeatherCell.self)) ({ indexPath, model, cell in
                if CoreLocationManager.shared.currLocation.value != nil && indexPath == 0 {
                    // 현 위치 셀 세팅
                } else {
                    cell.configure(model: model)
                }
            }).disposed(by: disposeBag)
        
//        viewModel.state.currLocationWeather
//            .bind(to: regionListView.getCollectionView.rx.)
        
        
        // ViewController ➡️ ViewModel
        viewModel.action.onNext(.viewDidLoad)
        
        
        // View ➡️ ViewController
        regionListView.getCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        regionListView.getCollectionView.rx.modelSelected(CurrentWeather.self)
            .asDriver()
            .drive(with: self) { owner, model in
                // TODO: Main 화면 present
                dump(model)
                os_log(.debug, log: owner.log, "Main 화면 present")
            }.disposed(by: disposeBag)
    }
}

// MARK: - UITableView Methods

private extension RegionWeatherListViewController {
    func configureTableView() {
        regionListView.getCollectionView.register(RegionWeatherCell.self, forCellWithReuseIdentifier: RegionWeatherCell.identifier)
    }
}

extension RegionWeatherListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width - sectionInset.left * 2
        let height: CGFloat = 200
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }
}

// MARK: - SearchResultViewControllerDelegate

extension RegionWeatherListViewController: SearchResultViewControllerDelegate {
    func cellDidTapped() {
        searchController.searchBar.resignFirstResponder()
    }
}
