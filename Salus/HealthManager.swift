//
//  HealthManager.swift
//  Salus
//
//  Created by MikelAlc on 7/30/25.
//  Based on Tutorial by Jason Dubon:
//  https://youtu.be/7vOF1kGnsmo?si=68NJ4VoYDv04HeDo

import Foundation
import HealthKit

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
        
        let healthTypes: Set = [steps,calories]
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes )
                fetchTodaySteps()
                fetchTodayCalories()
            } catch {
                print("Error Fetching Health Data")
            }
        }
    }
    
    func fetchTodaySteps(){
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("Error Fetching Today's Step Data")
                return
            }
            let stepCount = quantity.doubleValue(for: .count())
            let activity = Activity(id: 0, title: "Today's Steps", subtitle: "Goal: 10,000", imageName: "figure.walk", imageColor: .green, amount:stepCount.formattedString())
            DispatchQueue.main.async{
                self.activities["todaySteps"] = activity
            }
            print(stepCount.formattedString())
        }
            
        healthStore.execute(query)
    }
    
    func fetchTodayCalories(){
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate){ _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("Error Fetching Today's Calorie Data")
                return
            }
            let caloriesBurned = quantity.doubleValue(for: .kilocalorie())
            let activity = Activity(id: 1, title: "Calories Burned Today", subtitle: "Goal: 400", imageName: "flame", imageColor: .orange, amount:caloriesBurned.formattedString())
            DispatchQueue.main.async{
                self.activities["todayCalories"] = activity
            }
            print(caloriesBurned.formattedString())
            
        }
        
        healthStore.execute(query)
    }
    
}
