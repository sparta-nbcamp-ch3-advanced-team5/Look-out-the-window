//
//  RegionWeatherListViewController.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/21/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

/// 지역 리스트 ViewController
final class RegionWeatherListViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = RegionWeatherListViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
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
            .drive(regionListView.getTableView.rx.items(
                cellIdentifier: RegionWeatherCell.identifier, cellType: RegionWeatherCell.self)) ({ _, weather, cell in
                    cell.configure(temp: weather.temp,
                                   maxTemp: weather.maxTemp,
                                   minTemp: weather.minTemp,
                                   location: weather.location,
//                                   rive: weather.rive,
                                   rive: Rive.partlyCloudy,
                                   weather: weather.weather)
            })
            .disposed(by: disposeBag)
        
        // ViewController ➡️ ViewModel
        regionListView.getTableView.rx.modelSelected(RegionWeatherCell.self)
            .bind(with: self) { owner, cell in
                // TODO: Main 화면 present
            }.disposed(by: disposeBag)
        
        viewModel.action.onNext(.viewDidLoad)
        
        
        // View ➡️ ViewController
        regionListView.getTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        regionListView.getTableView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                print(indexPath)
            }.disposed(by: disposeBag)
    }
}

// MARK: - UITableView Methods

private extension RegionWeatherListViewController {
    func configureTableView() {
        regionListView.getTableView.register(RegionWeatherCell.self, forCellReuseIdentifier: RegionWeatherCell.identifier)
    }
}

extension RegionWeatherListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

// MARK: - SearchResultViewControllerDelegate

extension RegionWeatherListViewController: SearchResultViewControllerDelegate {
    func cellDidTapped() {
        searchController.searchBar.resignFirstResponder()
    }
}
