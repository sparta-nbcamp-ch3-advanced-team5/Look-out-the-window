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
    
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults = PublishRelay<[MKLocalSearchCompletion]>()
    
    // MARK: - UI Components
    
    private let searchResultView = SearchResultView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureTableView()
        bind()
    }
}

// MARK: - UI Methods

private extension SearchResultViewController {
    func setupUI() {
        setAppearance()
        setDelegates()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.view.backgroundColor = .mainBackground
    }
    
    func setDelegates() {
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
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
        // ViewController ➡️ View
        searchResults.asDriver(onErrorJustReturn: [])
            .drive(searchResultView.getTableView.rx.items(cellIdentifier: SearchResultCell.identifier, cellType: SearchResultCell.self)) { indexPath, result, cell in
                cell.configure(address: result.title)
            }.disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate & Methods

private extension SearchResultViewController {
    func configureTableView() {
        searchResultView.getTableView.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.identifier)
    }
}

extension SearchResultViewController: UITableViewDelegate {
    
}

// MARK: - UISearchBarDelegate

extension SearchResultViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension SearchResultViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults.accept(completer.results)
        searchResultView.getTableView.reloadData()
    }
}


