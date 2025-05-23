//
//  MainSectionDataModel.swift
//  Look-out-the-window
//
//  Created by GO on 5/21/25.
//

import RxDataSources

/*
 struct WeatherState: Decodable {
     let id: Int // 날씨 상태 ID
     let main: String // 날씨 매개변수 그룹(비,눈 등)
     let icon: String // 날씨 아이콘 ex) https://openweathermap.org/img/wn/(id)@2x.png
 }
 */

// MARK: - 각 섹션 DataModel (수정 필요해 보임)
struct HourlyModel {
    let hour: String      // 포맷 수정  ( 12시간 -> Cell 12개 정도)
    let temperature: String  // 섭씨
    // weatherState
    let weatherInfo: String // Asset네이밍 변환받아 전달받을 예정
}

struct DailyModel {
    // 요일, 하늘상태(이미지 -> String), 최저 - 최고 온도
    let day: String
    let high: String
    let low: String
    let weatherInfo: String // Asset네이밍 변환받아 전달받을 예정
}

// TODO: - DetailModel은 종류가 많으니까 enum으로 하는 것도 IDEA
struct DetailModel {
    // Cell에 UIView 각각 배치 예정
    let title: String
    let value: String
    // TODO: 이미지..? 필요한가
    let weatherInfo: String // 임시 -> 아이콘용
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



