//
//  RegionListViewController.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/21/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

/// 지역 리스트 ViewController
final class RegionListViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = RegionListViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let searchController: UISearchController
    private let searchResultVC = SearchResultViewController()
    
    private let regionListView = RegionListView()
    
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
        Task {
            await CoreLocationManager.shared.convertCurrCoordToAddress()
            await CoreLocationManager.shared.searchAddress(of: "반송동")
        }
    }
}

// MARK: - UI Methods

private extension RegionListViewController {
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
        
        searchController.searchBar.placeholder = "도시 또는 공항 검색"
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = true
    }
    
    func setDelegates() {
        searchController.searchBar.delegate = searchResultVC
        
        regionListView.getTableView.dataSource = self
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
        regionListView.getTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        regionListView.getTableView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                print(indexPath)
            }.disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate & Methods

private extension RegionListViewController {
    func configureTableView() {
        regionListView.getTableView.register(RegionCell.self, forCellReuseIdentifier: RegionCell.identifier)
    }
}

extension RegionListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

// MARK: - UITableViewDataSource

extension RegionListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RegionCell.identifier, for: indexPath) as? RegionCell else {
            return UITableViewCell()
        }
        
        cell.configure()
        return cell
    }
}
