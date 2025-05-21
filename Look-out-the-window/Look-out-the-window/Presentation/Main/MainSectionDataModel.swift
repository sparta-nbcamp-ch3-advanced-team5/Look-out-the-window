//
//  MainSectionDataModel.swift
//  Look-out-the-window
//
//  Created by GO on 5/21/25.
//

import RxDataSources

// MARK: - 각 섹션 DataModel (수정 필요해 보임)
struct HourlyModel {
    let hour: String        // "09:00" 등 (날짜 포맷 변환 필요)
    let temperature: String // "20℃" 등 (단위 변환 및 포맷팅)
}


struct DailyModel {
    let day: String      // "월", "화" 등
    let high: String     // "25℃"
    let low: String      // "15℃"
}


struct DetailModel {
    let title: String    // 예) "자외선지수", "일출", "일몰", "바람", "강수량", "체감기온", "습도"
    let value: String    // 예) "높음", "05:20", "19:45", "3m/s NW", "5mm", "22℃", "70%"
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



