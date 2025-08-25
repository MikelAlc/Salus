//
//  HealthManager.swift
//  Salus
//
//  Created by MikelAlc on 7/30/25.
//  Based on Tutorial by Jason Dubon:
//  https://youtu.be/7vOF1kGnsmo?si=68NJ4VoYDv04HeDo

import Foundation
import HealthKit
import SwiftUI

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}

extension Double {
    func formattedString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}

class HealthManager: ObservableObject {
    
    let healthStore = HKHealthStore()
    
    @Published var activities: [String:Activity] = [:]
    
    init(){
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let distance = HKQuantityType(.distanceWalkingRunning)
        
        let healthTypes: Set = [steps,calories,distance]
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes )
                
                let stepsToday = try await fetchTodayQuantity(
                    type: HKQuantityType(.stepCount),
                    unit: .count(),
                    errorMessage: "Steps"
                )
                
                let caloriesToday = try await fetchTodayQuantity(
                    type: HKQuantityType(.activeEnergyBurned),
                    unit: .kilocalorie(),
                    errorMessage: "Calorie"
                )
                
                let distanceToday = try await fetchTodayQuantity(
                    type: HKQuantityType(.distanceWalkingRunning),
                    unit: .meterUnit(with: .kilo),
                    errorMessage: "Distance"
                )
                
                DispatchQueue.main.async {
                    self.activities["todaySteps"] = Activity(
                        id: 0,
                        title: "Today's Steps",
                        subtitle: "Goal: 10,000",
                        imageName: "figure.walk",
                        imageColor: .green,
                        amount: stepsToday.formattedString()
                    )
                    
                    self.activities["todayCalories"] = Activity(
                        id: 1,
                        title: "Calories Burned Today",
                        subtitle: "Goal: 400",
                        imageName: "flame",
                        imageColor: .orange,
                        amount: caloriesToday.formattedString()
                    )
                    
                    self.activities["todayDistance"] = Activity(
                        id: 2,
                        title: "Distance Traveled Today",
                        subtitle: "Goal: 5 KM",
                        imageName: "shoeprints.fill",
                        imageColor: .blue,
                        amount: distanceToday.formattedString()
                    )
                }
                
            } catch {
                print("Error Fetching Health Data:", error)
            }
        }
    }
    
    func fetchTodayQuantity(
        type: HKQuantityType,
        unit: HKUnit,
        errorMessage: String
    ) async throws -> Double {
        
        try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: .startOfDay,end: Date())
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let quantatity = result?.sumQuantity() else {
                    print("Error Fetching Today's \(errorMessage) Data")
                    continuation.resume(returning: 0.0)
                    return
                }
                
                let value = quantatity.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            self.healthStore.execute(query)
        }
    }
}
