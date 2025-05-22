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
        let container = NSPersistentContainer(name: "WeatherDataEntity")
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
    func saveWeatherData(latitude: Double,
                         longitude: Double,
                         address: String,
                         temperature: String,
                         weatherInfo: String,
                         timestamp: Date = Date()) {
        let weather = WeatherDataEntity(context: context)
        weather.latitude = latitude
        weather.longitude = longitude
        weather.address = address
        weather.temperature = temperature
        weather.weatherInfo = weatherInfo
        weather.timestamp = timestamp

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
