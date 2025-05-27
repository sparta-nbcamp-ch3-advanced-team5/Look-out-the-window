//
//  CoreDataManager.swift
//  Look-out-the-window
//
//  Created by 윤주형 on 5/22/25.
//

import CoreData
import UIKit

final class CoreDataManager {
    static let shared = CoreDataManager()

    private init() {}


    //주형: 명시적 데이터 모델 로딩 방식 이유: model 엔티티가 중복되는 오류가 발생했었음
    lazy var persistentContainer: NSPersistentContainer = {
        guard let modelURL = Bundle.main.url(forResource: "CoreDataStorage", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("CoreData 모델 로드 실패")
        }

        let container = NSPersistentContainer(name: "CoreDataStorage", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData PersistentStore 로딩 실패: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: create 주형: 수정할 부분 위도,경도 param 필요없어짐
    func saveWeatherData(current: CurrentWeather) {
        let weather = WeatherDataEntity(context: context)
        weather.latitude = current.lat
        weather.longitude = current.lng
        weather.address = current.address
        weather.temperature = current.temperature
        weather.currentTime = Int64(current.currentTime)
        weather.maxTemp = current.maxTemp
        weather.minTemp = current.minTemp
        weather.tempFeelLike = current.tempFeelLike
        weather.skyInfo = current.skyInfo
        weather.pressure = current.pressure
        weather.humidity = current.humidity
        weather.clouds = current.clouds
        weather.uvi = current.uvi
        weather.visibility = current.visibility
        weather.windSpeed = current.windSpeed
        weather.windDeg = current.windDeg
        weather.rive = current.rive
        weather.currentMomentValue = current.currentMomentValue
        weather.timestamp = Date()
        weather.isCurrLocation = false


        //모델에 속성명 맞게 수정
        // 시간별 날씨 저장 (HourlyWeatherEntity)
        current.hourlyModel.forEach { hour in
            let hourly = HourlyWeatherEntity(context: context)
            hourly.time = String(hour.hour)
            hourly.temperature = hour.temperature
            hourly.skyInfo = hour.weatherInfo
            hourly.weather = weather
            weather.addToHourly(hourly)
        }

        // 일별 날씨 저장 (DailyWeatherEntity)
        current.dailyModel.forEach { day in
            let daily = DailyWeatherEntity(context: context)
            daily.currentTime = Int64(day.unixTime)
            daily.day = day.day
            daily.minTemp = day.low
            daily.maxTemp = day.high
            daily.skyInfo = day.weatherInfo
            daily.weather = weather
            weather.addToDaily(daily)
        }

        do {
            try context.save()
        } catch {
            print("\(error.localizedDescription)")
        }
    }

    //MARK: update 주소값을 받아서 업데이트
    func updateWeather(for address: String, with updateWeather: CurrentWeather) {
        let request: NSFetchRequest<WeatherDataEntity> = WeatherDataEntity.fetchRequest()
        request.predicate = NSPredicate(format: "address == %@", address)

        do {
            if let entity = try context.fetch(request).first {
                entity.temperature = updateWeather.temperature
                entity.maxTemp = updateWeather.maxTemp
                entity.minTemp = updateWeather.minTemp
                entity.tempFeelLike = updateWeather.tempFeelLike
                entity.skyInfo = updateWeather.skyInfo
                entity.pressure = updateWeather.pressure
                entity.humidity = updateWeather.humidity
                entity.clouds = updateWeather.clouds
                entity.uvi = updateWeather.uvi
                entity.visibility = updateWeather.visibility
                entity.windSpeed = updateWeather.windSpeed
                entity.windDeg = updateWeather.windDeg
                entity.rive = updateWeather.rive
                entity.currentTime = Int64(updateWeather.currentTime)
                entity.currentMomentValue = updateWeather.currentMomentValue
                entity.sunriseTime = Int64(updateWeather.sunriseTime)
                entity.sunsetTime = Int64(updateWeather.sunsetTime)
                try context.save()
            }
            else {
                print("update 되는 데이터 없음")
            }
        } catch {
            print("주소 기반 fetch 실패: \(error.localizedDescription)")

        }
    }

    //MARK: 주소값을 받아서 삭제하는 메서드
    func deleteWeather(for address: String) {
        let request: NSFetchRequest<WeatherDataEntity> = WeatherDataEntity.fetchRequest()
        request.predicate = NSPredicate(format: "address == %@", address)

        do {
            if let objectToDelete = try context.fetch(request).first {
                context.delete(objectToDelete)
                try context.save()
            }else {
                print("삭제할 데이터 없음")
            }
        } catch {
            print("주소 기반 fetch 실패: \(error.localizedDescription)")
        }
    }

    func fetchWeather(for address: String) -> WeatherDataEntity? {
        let request: NSFetchRequest<WeatherDataEntity> = WeatherDataEntity.fetchRequest()
        request.predicate = NSPredicate(format: "address == %@", address)
        request.fetchLimit = 1

        do {
            return try context.fetch(request).first
        } catch {
            print("주소 기반 fetch 실패: \(error.localizedDescription)")
            return nil
        }
    }


    //MARK: fetch
    func fetchWeatherData() -> [WeatherDataEntity] {
        let request: NSFetchRequest<WeatherDataEntity> = WeatherDataEntity.fetchRequest()

        // hour.hour < unix 값이라 String값으로 변환 메서드 작성 불러온 값을 변환
        // NSSet unix 값으로 들어오면 정렬하기 line 163

        do {
            let result = try context.fetch(request)
            print("coredata fetch 출력 \(result)")
            return result
        } catch {
            print("\(error.localizedDescription)")
            return []
        }
    }

    // delete
    func delete(_ data: WeatherDataEntity) {
        context.delete(data)
        do {
            try context.save()
        } catch {
            print("\(error.localizedDescription)")
        }
    }

    // deleteAll
    func deleteAll() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WeatherDataEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("\(error.localizedDescription)")
        }
    }

    //주형 동환님 앱 실행시 위도 경도 저장
    func saveLatLngAppStarted(current: CurrentWeather, latitude: Double, longitude: Double) {
        let weather = WeatherDataEntity(context: context)
        weather.latitude = latitude
        weather.longitude = longitude

        do {
            try context.save()
        } catch {
            print("\(error.localizedDescription)")
        }
    }
}

extension WeatherDataEntity {

    // 시간별 날씨 정렬
    var sortedHourlyArray: [HourlyWeatherEntity] {
        guard let set = hourly as? Set<HourlyWeatherEntity> else { return [] }
        //주형 임시 "" 처리
        let hourlySetSorted = set.sorted { $0.time ?? "" < $1.time ?? "" }
        print("hourlySetSorted가 정렬 되었는지 확인: \(hourlySetSorted)")
        return hourlySetSorted
    }

    // 일별 날씨 정렬
    var sortedDailyArray: [DailyWeatherEntity] {
        guard let set = daily as? Set<DailyWeatherEntity> else { return [] }
        let DailySetsorted = set.sorted { $0.currentTime < $1.currentTime }
        print("DailySetsorted가 정렬 되었는지 확인: \(DailySetsorted)")
        return DailySetsorted
    }
    /// CurrentWeather 객체 생성 메서드
    func toCurrentWeatherModel() -> CurrentWeather {
        return CurrentWeather(
            address: self.address ?? "--",
            lat: self.latitude,
            lng: self.longitude,
            currentTime: Int(self.currentTime),
            currentMomentValue: self.currentMomentValue,
            sunriseTime: Int(self.sunriseTime),
            sunsetTime: Int(self.sunsetTime),
            temperature: self.temperature ?? "--",
            maxTemp: self.maxTemp ?? "--",
            minTemp: self.minTemp ?? "--",
            tempFeelLike: self.tempFeelLike ?? "--",
            skyInfo: self.skyInfo ?? "--",
            pressure: self.pressure ?? "--",
            humidity: self.humidity ?? "--",
            clouds: self.clouds ?? "--",
            uvi: self.uvi ?? "--",
            visibility: self.visibility ?? "--",
            windSpeed: self.windSpeed ?? "--",
            windDeg: self.windDeg ?? "--",
            rive: self.rive ?? "",
            hourlyModel: self.sortedHourlyArray.map { $0.toModel() },
            dailyModel: self.sortedDailyArray.map { $0.toModel() },
            isCurrLocation: self.isCurrLocation,
            isUserSaved: self.isUserSaved,
            rainPerHour: self.rainPerHour,
            snowPerHour: self.snowPerHour
        )
    }

}

extension HourlyWeatherEntity {
    func toModel() -> HourlyModel {
        return HourlyModel(
            hour: Int(self.time ?? "0") ?? 0,
            temperature: self.temperature ?? "--",
            weatherInfo: self.skyInfo ?? "--"
        )
    }
}

extension DailyWeatherEntity {
    func toModel() -> DailyModel {
        return DailyModel(
            unixTime: Int(self.currentTime),
            day: self.day ?? "--",
            high: self.maxTemp ?? "--",
            low: self.minTemp ?? "--",
            weatherInfo: self.skyInfo ?? "--",
            maxTemp: Int(self.maxTemp ?? "") ?? 0,
            minTemp: Int(self.minTemp ?? "") ?? 0,
            temperature: self.temperature ?? "--"
        )
    }
}




