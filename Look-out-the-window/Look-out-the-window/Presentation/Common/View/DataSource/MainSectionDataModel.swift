//
//  MainSectionDataModel.swift
//  Look-out-the-window
//
//  Created by GO on 5/21/25.
//

import UIKit
import RxDataSources

/// Header
enum SectionHeaderInfo: Int, CaseIterable {
    case hourly
    case daily

    var icon: String {
        switch self {
        case .hourly: return "clock"
        case .daily: return "calendar"
        }
    }

    var title: String {
        switch self {
        case .hourly: return "시간별 예보"
        case .daily: return "일별 예보"
        }
    }
}

enum MainSectionItem {
    case hourly(HourlyModel)
    case daily(DailyModel)
    case detail(DetailModel)
}

struct MainSection {
    var items: [MainSectionItem]
}

extension MainSection: SectionModelType {
    typealias Item = MainSectionItem

    init(original: MainSection, items: [MainSectionItem]) {
        self = original
        self.items = items
    }
}



