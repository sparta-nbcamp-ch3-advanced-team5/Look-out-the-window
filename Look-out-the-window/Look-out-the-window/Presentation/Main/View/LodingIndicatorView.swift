//
//  LodingIndicatorView.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/23/25.
//

import UIKit
import SnapKit
import Then
import RiveRuntime

final class LodingIndicatorView: UIView {
    
    private let titleLabel = UILabel().then {
        $0.text = "새로운 날씨를 불러와요."
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 16, weight: .regular)
    }
    
    private let riveViewModel = RiveViewModel(fileName: "LoadingSun", stateMachineName: "State Machine 1")
    private var riveView = RiveView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func play() {
        riveViewModel.play()
    }
    
    func pause() {
        riveViewModel.pause()
    }
}

private extension LodingIndicatorView {
    func setupUI() {
        riveView = riveViewModel.createRiveView()
        riveViewModel.pause()
        self.backgroundColor = .clear
        self.addSubviews(titleLabel, riveView)
        configureLayout()
    }
    
    func configureLayout() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview().offset(-25)
        }
        riveView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(titleLabel.snp.trailing).offset(10)
            $0.width.height.equalTo(30)
        }
    }
}
