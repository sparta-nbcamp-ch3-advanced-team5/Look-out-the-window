//
//  BackgroundViewController.swift
//  Look-out-the-window
//
//  Created by 정근호 on 5/20/25.
//

import UIKit

import RxCocoa
import RxSwift
import RxGesture
import SnapKit
import Then

final class BackgroundViewController: UIViewController {
    
    private let colorSet = [UIColor.mainBackground, UIColor.secondaryBackground, UIColor.cellStart, UIColor.cellEnd]
    
    let disposeBag = DisposeBag()

    // MARK: - UI Components
    private lazy var backgroundViewList = [BackgroundView]()
    private lazy var backgroundView = BackgroundView(frame: .zero, setBackgroundColor: colorSet[0])
    
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
    
    private lazy var pageController = UIPageControl().then {
        $0.numberOfPages = colorSet.count
        $0.currentPage = 0
        $0.currentPageIndicatorTintColor = .white
        $0.pageIndicatorTintColor = .systemGray
    }
    
    // MARK: - Initializers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setBackgroundView()
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
        view.addSubviews(backgroundView, pageController, locationButton, listButton)
        
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        pageController.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(UIScreen().bounds.height / 35.0)
            $0.centerX.equalToSuperview()
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
    private func setBackgroundView() {
        for i in 0..<colorSet.count {
            backgroundViewList.append(BackgroundView(frame: .zero, setBackgroundColor: colorSet[i]))
        }
    }
    
    private func bind() {
                
        Observable
            .merge(
                self.view.rx.gesture(.swipe(direction: .left)).asObservable(),
                self.view.rx.gesture(.swipe(direction: .right)).asObservable()
            )
            .bind { [weak self] gesture in
                guard let self = self else { return }
                guard let gesture = gesture as? UISwipeGestureRecognizer else { return }
                switch gesture.direction {
                case .left:
                    self.pageController.currentPage += 1
                case .right:
                    self.pageController.currentPage -= 1
                default:
                    break
                }
                resetBackground()
            }
            .disposed(by: self.disposeBag)
        
    }
    
    private func resetBackground() {
        // 기존 배경 뷰 제거
        self.backgroundView.removeFromSuperview()
        
        // 새 배경 뷰 할당
        self.backgroundView = self.backgroundViewList[self.pageController.currentPage]
        
        // 새 배경 뷰 맨뒤에 추가
        self.view.insertSubview(self.backgroundView, at: 0)
        
        self.backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

