//
//  SearchResultViewController.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/22/25.
//

import UIKit
import OSLog

import RxCocoa
import RxRelay
import RxSwift
import SnapKit

/// 검색 결과 ViewController
final class SearchResultViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    weak var delegate: SearchResultViewControllerDelegate?
    
    private let viewModel = SearchResultViewModel()
    private let disposeBag = DisposeBag()
    
    /// 검색어 `PublishRelay`
    private let searchTextRelay = PublishRelay<String>()
    
    // MARK: - UI Components
    
    private let searchResultView = SearchResultView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureTableView()
    }
}

// MARK: - UI Methods

private extension SearchResultViewController {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
        bind()
    }
    
    func setAppearance() {
        self.view.backgroundColor = .mainBackground
    }
    
    func setViewHierarchy() {
        self.view.addSubview(searchResultView)
    }
    
    func setConstraints() {
        searchResultView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind() {
        // ViewController ➡️ ViewModel
        searchTextRelay.asInfallible()
            .debounce(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .subscribe(with: self) { owner, text in
                owner.viewModel.action.onNext(.searchLocation(text: text))
            }.disposed(by: disposeBag)
        
        searchResultView.getTableView.rx.modelSelected(SearchResultModel.self)
            .bind(with: self) { owner, model in
                owner.delegate?.cellDidTapped()
                owner.viewModel.action.onNext(.localSearch(location: model.address))
            }.disposed(by: disposeBag)


        // ViewModel ➡️ ViewController
        viewModel.state.searchResults.asDriver(onErrorJustReturn: [])
            .drive(searchResultView.getTableView.rx.items(
                cellIdentifier: SearchResultCell.identifier, cellType: SearchResultCell.self)) { _, model, cell in
                    cell.configure(model: model)
                }.disposed(by: disposeBag)
        
        viewModel.state.localSearchResult.asDriver(onErrorJustReturn: LocationModel())
            .drive(with: self) { owner, location in
                // TODO: - isSavedLocation 수정
                let registerVC = RegisterViewController(viewModel: RegisterViewModel(address: location.toAddress(), lat: location.lat, lng: location.lng), isSavedLocation: false)
                let naviVC = UINavigationController(rootViewController: registerVC)
                self.present(naviVC, animated: true)
                os_log(.debug, log: owner.log, "Register 화면 present")
            }.disposed(by: disposeBag)
        
        
        // View ➡️ ViewController
        searchResultView.getTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate & Methods

private extension SearchResultViewController {
    func configureTableView() {
        searchResultView.getTableView.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.identifier)
    }
}

extension SearchResultViewController: UITableViewDelegate {
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

// MARK: - UISearchBarDelegate

extension SearchResultViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTextRelay.accept(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchTextRelay.accept("")
    }
}
