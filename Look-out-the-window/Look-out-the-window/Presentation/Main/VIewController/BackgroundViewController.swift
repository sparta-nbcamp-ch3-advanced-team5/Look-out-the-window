//
//  BackgroundViewController.swift
//  Look-out-the-window
//
//  Created by 정근호 on 5/20/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

final class BackgroundViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var backgroundView = BackgroundView()
    
    private lazy var locationButton = UIButton().then {
        // 버튼의 SFSymbol 이미지 크기 변경 시 사용
//        let config = UIImage.SymbolConfiguration(pointSize: 44, weight: .regular)
        $0.setImage(UIImage(systemName: "location.fill", withConfiguration: nil), for: .normal)
        $0.tintColor = .label
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    private lazy var listButton = UIButton().then {
//        let config = UIImage.SymbolConfiguration(pointSize: 44, weight: .regular)
        $0.setImage(UIImage(systemName: "list.bullet", withConfiguration: nil), for: .normal)
        $0.tintColor = .label
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    // MARK: - Initializers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        
        guard let apiKeyEncoding = Bundle.main.object(forInfoDictionaryKey: "API_KEY_ENCODING") as? String,
              let apiKeyDecoding = Bundle.main.object(forInfoDictionaryKey: "API_KEY_DECODING") as? String,
              let clientId = Bundle.main.object(forInfoDictionaryKey: "CLIENT_ID") as? String,
              let clientSecret = Bundle.main.object(forInfoDictionaryKey: "CLIENT_SECRET") as? String else { return }
        print(apiKeyEncoding)
        print(apiKeyDecoding)
        print(clientId)
        print(clientSecret)
    }
    
    // MARK: - UI & Layout
    private func setupUI() {
        view.addSubviews(backgroundView, locationButton, listButton)
        
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        locationButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.width.height.equalTo(44)
        }
        
        listButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.width.height.equalTo(44)
        }
    }
    
    
    // MARK: - Private Methods
    private func bind() {
        backgroundView.rx.tapGesture()
    }
}
