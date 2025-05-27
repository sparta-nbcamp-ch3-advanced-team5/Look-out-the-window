//
//  MainLoadingIndicator.swift
//  Look-out-the-window
//
//  Created by 정근호 on 5/27/25.
//

import UIKit
import SnapKit
import RiveRuntime

final class MainLoadingIndicator: UIView {
    
    let riveViewModel = RiveViewModel(
        fileName: "LoadingSun",
        stateMachineName: "State Machine 1",
    )
    
    /// Rive 로딩 인디케이터
    private lazy var loadingRiveView: RiveView = {
        let view = riveViewModel.createRiveView()
        view.preferredFramesPerSecond = 10
        view.isUserInteractionEnabled = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        riveViewModel.play()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
