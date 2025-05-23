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

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataStorage")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData 로딩 실패: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: create
    func saveWeatherData(current: CurrentWeather, latitude: Double, longitude: Double) {
        let weather = WeatherDataEntity(context: context)
        weather.latitude = latitude
        weather.longitude = longitude
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
        weather.currentMomentValue = String(current.currentMomentValue) // String으로 변환
        weather.timestamp = Date()

        // 시간별 날씨 저장 (HourlyWeatherEntity)
        current.hourlyModel.forEach { hour in
            let hourly = HourlyWeatherEntity(context: context)
            hourly.time = hourly.time
            hourly.temperature = hourly.temperature
            hourly.skyInfo = hourly.skyInfo
            hourly.weather = weather
            weather.addToHourly(hourly)
        }

        // 일별 날씨 저장 (DailyWeatherEntity)
        current.dailyModel.forEach { day in
            let daily = DailyWeatherEntity(context: context)
            daily.date = daily.date
            daily.minTemp = daily.minTemp
            daily.maxTemp = daily.maxTemp
            daily.skyInfo = daily.skyInfo
            daily.weather = weather
            weather.addToDaily(daily)
        }

        do {
            try context.save()
        } catch {
            print("\(error.localizedDescription)")
        }
    }


    //MARK: fetch
    func fetchWeatherData() -> [WeatherDataEntity] {
        let request: NSFetchRequest<WeatherDataEntity> = WeatherDataEntity.fetchRequest()

        do {
            let result = try context.fetch(request)
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
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = WeatherDataEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("\(error.localizedDescription)")
        }
    }
}
