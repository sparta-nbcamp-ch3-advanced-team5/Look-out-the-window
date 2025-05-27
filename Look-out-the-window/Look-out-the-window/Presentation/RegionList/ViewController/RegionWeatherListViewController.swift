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

    public let viewModel = RegionWeatherListViewModel()
    private let disposeBag = DisposeBag()
    
    private let dataSource = RxTableViewSectionedAnimatedDataSource<RegionWeatherListSection>(animationConfiguration: AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .automatic, deleteAnimation: .fade)) { dataSource, tableView, indexPath, item in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RegionWeatherCell.identifier, for: indexPath) as? RegionWeatherCell else { return UITableViewCell() }
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
        
        configureTableView()
        configureDataSource()
        setupUI()
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
            .drive(regionListView.getTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        
        // ViewController ➡️ ViewModel
        regionListView.getTableView.rx.itemDeleted
            .subscribe(with: self) { owner, indexPath in
                owner.viewModel.action.onNext(.itemDeleted(indexPath: indexPath))
            } onError: { owner, error in
                os_log(.error, log: owner.log, "itemDeleted: \(error.localizedDescription)")
            }.disposed(by: disposeBag)

        viewModel.action.onNext(.viewDidLoad)


        // View ➡️ ViewController
        regionListView.getTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
//        regionListView.getTableView.rx.itemSelected
//            .asDriver()
//            .drive(with: self) { owner, model in
//                // TODO: Main 화면 present
//                owner.navigationController?.pushViewController(WeatherDetailViewController(viewModel: WeatherDetailViewModel()), animated: true)
                dump(model)
                // 주형: index 아이템 클릭시 주소 저장
                if let address = model.address {
                     UserDefaults.standard.set(address, forKey: "LastViewedWeatherAddress")
                 }

                 if let entity = CoreDataManager.shared.fetchWeather(for: model.address) {
                     let viewModel = WeatherDetailViewModel(entity: entity)
                     let detailVC = WeatherDetailViewController(viewModel: viewModel)
                     owner.navigationController?.pushViewController(detailVC, animated: true)
                 }
                os_log(.debug, log: owner.log, "Main 화면 present")
            }.disposed(by: disposeBag)
        
        
        // MARK: - 근호님 코드
        // 현재 index값 안받아와짐
        Observable.zip(
            regionListView.getTableView.rx.modelSelected(CurrentWeather.self),
            regionListView.getTableView.rx.itemSelected
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
    func cellDidTapped() {
        searchController.searchBar.resignFirstResponder()
    }
}
