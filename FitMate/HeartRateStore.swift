//
//  HeartRateStore.swift
//  FitMate
//
//  Created by eversense on 2023/03/09.
//

import HealthKit

class HeartRateStore: ObservableObject {
    let healthStore = HKHealthStore()

    func authorizeHealthKit() {
        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
        healthStore.requestAuthorization(toShare: nil, read: healthKitTypes) { (success, error) in
            if success {
                print("HealthKit authorization succeeded")
            } else {
                print("HealthKit authorization failed")
            }
        }
    }

    func fetchHeartRateSamples(for date: Date, completion: @escaping ([HKQuantitySample]?) -> Void) {
        // 心拍数の型を取得
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { (query, samples, error) in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion(nil)
                return
            }

            var result: [HKQuantitySample] = []
            let hourInterval = 3600.0
            var nextHour = startOfDay.timeIntervalSince1970 + hourInterval

            for sample in samples {
                let timestamp = sample.endDate.timeIntervalSince1970
                while timestamp > nextHour {
                    nextHour += hourInterval
                }
                if timestamp > nextHour - hourInterval / 2 {
                    result.append(sample)
                }
            }

            completion(result)
        }

        healthStore.execute(query)
    }
}
