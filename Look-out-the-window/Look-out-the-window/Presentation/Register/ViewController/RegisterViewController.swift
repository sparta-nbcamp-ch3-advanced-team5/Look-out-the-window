//
//  RegisterViewController.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/26/25.
//

import UIKit

import SnapKit
import Then
import RxSwift
import RxDataSources
import RxRelay

final class RegisterViewController: UIViewController {
    
    let detailView = WeatherDetailCollectionView()
    let disposeBag = DisposeBag()
    let viewModel: RegisterViewModel
    
    private let addButton = UIButton().then {
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
    }
    
    init(viewModel: RegisterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        
        bind()
    }
    
    func bind() {
        viewModel.action.onNext(.viewDidLoad)
        
        viewModel.state.currentWeather
            .compactMap{ $0 }
            .bind(to: detailView.rx.items(dataSource: detailView.detailDataSource))
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.viewModel.action.onNext(.plusButtonTapped)
            }.disposed(by: disposeBag)
    }
}

private extension RegisterViewController {
    func setupUI() {
        setNavigationBar()
        addViews()
        configureLayout()
    }
    
    func setNavigationBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
    }
    
    func addViews() {
        view.addSubviews(detailView)
    }
    
    func configureLayout() {
        detailView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

