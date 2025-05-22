//
//  SearchResultViewModel.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/22/25.
//

import Foundation
import MapKit
import OSLog

import RxRelay
import RxSwift

/// 검색 결과 ViewModel
final class SearchResultViewModel: NSObject, ViewModelProtocol {
    
    // MARK: - Properties
    
    private lazy var log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    let disposeBag = DisposeBag()
    
    private let searchCompleter = MKLocalSearchCompleter()
    
    // MARK: - Action (ViewController ➡️ ViewModel)
    
    enum Action {
        case searchText(text: String)
    }
    var action: AnyObserver<Action> {
        return state.actionSubject.asObserver()
    }
    
    // MARK: - State (ViewModel ➡️ ViewController)
    
    struct State {
        let actionSubject = PublishSubject<Action>()
        
        let searchResults = BehaviorRelay<[MKLocalSearchCompletion]>(value: [])
    }
    var state = State()
    
    // MARK: - Initializer
    
    override init() {
        super.init()
        
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
        
        state.actionSubject
            .subscribe(with: self) { owner, action in
                switch action {
                case let .searchText(text: text):
                    owner.searchLocation(searchText: text)
                }
            }.disposed(by: disposeBag)
    }
}

// MARK: - MapKit Methods

private extension SearchResultViewModel {
    func searchLocation(searchText: String) {
        if searchText.isEmpty {
            state.searchResults.accept([])
        }
        searchCompleter.queryFragment = searchText
    }
}

// MARK: - MapKit Delegate & Methods

extension SearchResultViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        state.searchResults.accept(completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        os_log(.error, log: log, "\(error.localizedDescription)")
    }
}

