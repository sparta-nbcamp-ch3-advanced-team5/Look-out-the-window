//
//  RegisterViewControllerDelegate.swift
//  Look-out-the-window
//
//  Created by 서동환 on 5/27/25.
//

import Foundation

/// `RegisterViewController` ➡️ `RegionWeatherListViewController`
protocol RegisterViewControllerDelegate: AnyObject {
    func modalWillDismissed()
}
