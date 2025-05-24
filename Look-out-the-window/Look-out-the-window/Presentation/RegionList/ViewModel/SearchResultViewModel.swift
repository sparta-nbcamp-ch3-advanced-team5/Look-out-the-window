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
    
    private var currLocalSearch: MKLocalSearch?
    private let searchCompleter = MKLocalSearchCompleter()
    
    // MARK: - Action (ViewController ➡️ ViewModel)
    
    enum Action {
        case searchLocation(text: String)
        case localSearch(location: String)
    }
    var action: AnyObserver<Action> {
        return state.actionSubject.asObserver()
    }
    
    // MARK: - State (ViewModel ➡️ ViewController)
    
    struct State {
        let actionSubject = PublishSubject<Action>()
        
        let searchResults = BehaviorRelay<[SearchResultModel]>(value: [])
        let localSearchResult = PublishRelay<LocationModel>()
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
                case let .searchLocation(text: text):
                    owner.searchLocation(of: text)
                case let .localSearch(location: location):
                    owner.getLocationModel(of: location)
                }
            }.disposed(by: disposeBag)
    }
}

// MARK: - MapKit Methods

private extension SearchResultViewModel {
    func searchLocation(of searchText: String) {
        if searchText.isEmpty {
            state.searchResults.accept([])
        }
        searchCompleter.queryFragment = searchText
    }
    
    func getLocationModel(of location: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = location
        
        let localSearch = MKLocalSearch(request: request)
        
        currLocalSearch?.cancel()
        currLocalSearch = localSearch
        
        defer {
            currLocalSearch = nil
        }
        
        Task {
            do {
                // TODO: - 검색 정확도 개선
                let response = try await localSearch.start()
                guard let item = response.mapItems.first else { return }
                let placemark = item.placemark
                
                guard let country = placemark.country,
                      let administrativeArea = placemark.administrativeArea,
                let coord = placemark.location?.coordinate else { return }
                let locality = placemark.locality ?? ""
                let subLocality = placemark.subLocality ?? placemark.thoroughfare ?? ""
                let location = LocationModel(country: country,
                                             administrativeArea: administrativeArea,
                                             locality: locality,
                                             subLocality: subLocality,
                                             lat: coord.latitude,
                                             lng: coord.longitude)
                os_log(.debug, log: log, "MKLocalSearch: \(location.country), \(location.administrativeArea), \(location.locality), \(location.subLocality)")
                
                state.localSearchResult.accept(location)
            } catch {
                os_log(.error, log: log, "MKLocalSearch error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - MapKit Delegate & Methods

extension SearchResultViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let models: [SearchResultModel] = completer.results.map {
            if $0.subtitle.isEmpty {
                return SearchResultModel(address: $0.title, titleHighlightRange: $0.titleHighlightRanges.first?.rangeValue)
            } else {
                return SearchResultModel(address: "\($0.title) \($0.subtitle)", titleHighlightRange: $0.titleHighlightRanges.first?.rangeValue)
            }
        }
        state.searchResults.accept(models)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        os_log(.error, log: log, "MKLocalSearchCompleter error: \(error.localizedDescription)")
    }
}
