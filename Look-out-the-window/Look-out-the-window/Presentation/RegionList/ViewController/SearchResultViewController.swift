//
//  SearchResultViewController.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/22/25.
//

import UIKit
import MapKit

import RxCocoa
import RxRelay
import RxSwift
import SnapKit

/// 검색 결과 ViewController
final class SearchResultViewController: UIViewController {
    
    // MARK: - Properties
    
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
                owner.viewModel.action.onNext(.searchText(text: text))
            }.disposed(by: disposeBag)
        
        // ViewModel ➡️ ViewController
        viewModel.state.searchResults.asDriver(onErrorJustReturn: [])
            .drive(searchResultView.getTableView.rx.items(cellIdentifier: SearchResultCell.identifier, cellType: SearchResultCell.self)) { indexPath, result, cell in
                cell.configure(address: result.title)
            }.disposed(by: disposeBag)
        
        searchResultView.getTableView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
//                owner.searchResults.value[indexPath.row]
            }.disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate & Methods

private extension SearchResultViewController {
    func configureTableView() {
        searchResultView.getTableView.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.identifier)
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
