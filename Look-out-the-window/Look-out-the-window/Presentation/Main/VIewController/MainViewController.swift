//
//  MainViewController.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/20/25.
//

import UIKit

import RxSwift
import SnapKit
import Then

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
        print(apiKey)
    }


}

