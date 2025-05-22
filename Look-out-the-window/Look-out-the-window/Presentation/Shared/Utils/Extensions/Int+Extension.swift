//
//  Int+Extension.swift
//  Look-out-the-window
//
//  Created by MJ Dev on 5/21/25.
//

import Foundation

extension Int {
    /// 유닉스 시간(TimeInterval)을 Date 객체로 변환합니다.
    /// - Returns: 해당 유닉스 시간을 나타내는 `Date` 객체입니다.
    func convertUnixTimeToDate() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(self))
    }
    
    /// 유닉스 시간을 "오전 1시", "오후 3시" 형식의 문자열로 변환합니다.
    /// - Returns: 시(hour) 정보를 포함한 문자열 (예: "오전 9시", "오후 3시").
    func convertUnixTimeToHourString() -> String {
        let date = self.convertUnixTimeToDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a hh시"
        var result = dateFormatter.string(from: date).components(separatedBy: " ")
        if result.count == 2 {
            let str = result[1]
            str.prefix(1) == "0" ? (result[1] = String(str.dropFirst())) : ()
        }
        return result.joined(separator: " ")
    }
    
    /// 유닉스 시간을 기준으로 요일 문자열을 반환합니다.
    /// - Returns: 해당 날짜의 요일을 문자열로 반환합니다 (예: "Monday", "화요일").
    func convertUnixTimeToWeekString() -> String {
        let date = self.convertUnixTimeToDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
    
    /// 특정 유닉스 시간에 해당하는 날짜의 시작과 끝 시간(유닉스 타임스탬프)을 계산합니다.
    /// - Parameter unixTime: 기준이 되는 유닉스 시간 (초 단위).
    /// - Returns: 해당 날짜의 시작 시각과 끝 시각의 유닉스 시간 범위를 튜플로 반환합니다.
    func getUnixRange(unixTime: TimeInterval) -> (startUnix: TimeInterval, endUnix: TimeInterval)? {
        let current = Date(timeIntervalSince1970: unixTime)
        let calendar = Calendar.current
        
        guard let startDate = calendar.startOfDay(for: current) as Date? else {
            return nil
        }
        
        let endDate = startDate.addingTimeInterval(86400 - 1)
        
        let startUnix = startDate.timeIntervalSince1970
        let endUnix = endDate.timeIntervalSince1970
        
        return (startUnix: startUnix, endUnix: endUnix)
    }
    /// 유닉스 타임스탬프(Int)를 "h:mm a" 형식의 문자열로 변환합니다.
    /// - Returns: 오전/오후 표시가 포함된 시간 문자열 (예: "8:15 AM").
    ///
    /// 이 메서드는 내부적으로 `convertUnixTimeToDate()`를 사용하여 `Date` 객체로 변환한 후,
    /// `DateFormatter`를 통해 시간과 AM/PM 형식으로 출력합니다.
    ///
    /// 사용 예:
    /// ```swift
    /// let timestamp: Int = 1684752000
    /// let timeString = timestamp.convertUnixToHourMinuteAndMark()
    /// print(timeString) // "6:00 AM"
    /// ```
    func convertUnixToHourMinuteAndMark() -> String {
        let date = self.convertUnixTimeToDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        return dateFormatter.string(from: date)
    }

}
