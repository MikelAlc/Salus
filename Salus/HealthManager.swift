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
import FamilyControls
import DeviceActivity

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}

extension Double {
    func formattedString(maximumFractionDigits: Int = 0) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = maximumFractionDigits
        
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}

struct ActivityConfig {
    let id: Int
    let title: String
    let subtitle: String
    let imageName: String
    let imageColor: Color
    let quantityType: HKQuantityType
    let unit: HKUnit
    let unitLabel: String
    let errorMessage: String
    let maximumFractionDigits: Int
}

class HealthManager: ObservableObject {
    
    let healthStore = HKHealthStore()
    
    @Published var activities: [String:Activity] = [:]
    
    private let activityConfigs: [String: ActivityConfig] = [
        "todaySteps": ActivityConfig(
            id: 0,
            title: "Today's Steps",
            subtitle: "Goal: 10,000",
            imageName: "shoeprints.fill",
            imageColor: .blue,
            quantityType: HKQuantityType(.stepCount),
            unit: .count(),
            unitLabel: "steps",
            errorMessage: "Step",
            maximumFractionDigits: 0
        ),
        "todayCalories": ActivityConfig(
            id: 1,
            title: "Calories Burned Today",
            subtitle: "Goal: 400",
            imageName: "flame.fill",
            imageColor: .orange,
            quantityType: HKQuantityType(.activeEnergyBurned),
            unit: .kilocalorie(),
            unitLabel: "cal",
            errorMessage: "Calorie",
            maximumFractionDigits: 0
        ),
        
        "todayDistance": ActivityConfig(
            id: 2,
            title: "Distance Traveled Today",
            subtitle: "Goal: 5 KM",
            imageName: "ruler.fill",
            imageColor: .green,
            quantityType: HKQuantityType(.distanceWalkingRunning),
            unit: .meterUnit(with: .kilo),
            unitLabel: "km",
            errorMessage: "Distance",
            maximumFractionDigits: 2
        )
    ]
    
    init(){
        
        let healthTypes: Set = Set(activityConfigs.values.map{ $0.quantityType })
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes )
                
                for (key,config) in activityConfigs {
                    let activity = try await fetchActivity(from:config)
                    DispatchQueue.main.async{
                        self.activities[key] = activity
                    }
                    /*
                     if let distance = activities["todayDistance"] {
                     if let value = Double(distance.amount) {
                     ScreenTimeManager.shared.enforceLockIfNeeded(distance: value)
                     }
                     }
                     */
                }
                
            } catch {
                print("Error Fetching Health Data:", error)
            }
        }
    }
    
    func fetchActivity(from config: ActivityConfig) async throws -> Activity {
        let value = try await fetchTodayQuantity(
            type: config.quantityType,
            unit: config.unit,
            errorMessage: config.errorMessage
        )
        
        return Activity(
            id: config.id,
            title: config.title,
            subtitle: config.subtitle,
            imageName: config.imageName,
            imageColor: config.imageColor,
            amount: value.formattedString(maximumFractionDigits: config.maximumFractionDigits) + " " + config.unitLabel
        )
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
