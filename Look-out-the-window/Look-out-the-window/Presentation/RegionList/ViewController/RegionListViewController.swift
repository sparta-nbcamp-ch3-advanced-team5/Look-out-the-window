//
//  RegionListViewController.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/21/25.
//

import UIKit

import SnapKit
import Then

final class RegionListViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = RegionListViewModel()
    
    // MARK: - UI Components
    
    private let regionListView = RegionListView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
}

private extension RegionListViewController {
    func setupUI() {
        setAppearance()
        setViewHierarchy()
        setConstraints()
    }
    
    func setAppearance() {
        self.view.backgroundColor = .mainBackground
    }
    
    func setViewHierarchy() {
        self.view.addSubview(regionListView)
    }
    
    func setConstraints() {
        regionListView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
