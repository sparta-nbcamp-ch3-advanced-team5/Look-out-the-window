//
//  SearchResultViewController.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/22/25.
//

import UIKit
import MapKit
import OSLog

import RxCocoa
import RxRelay
import RxSwift
import SnapKit

/// 검색 결과 ViewController
final class SearchResultViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
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
        searchCompleter.resultTypes = .address
    }
    
    func setDelegates() {
        searchCompleter.delegate = self
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

// MARK: - UISearchBarDelegate

extension SearchResultViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchResults.accept([])
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension SearchResultViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults.accept(completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        os_log(.error, log: log, "\(error.localizedDescription)")
    }
}
