//
//  StatisticsView.swift
//  Salus
//
//  Created by MikelAlc on 7/28/25.
//  Based on Tutorial by Jason Dubon:
//  https://youtu.be/7vOF1kGnsmo?si=68NJ4VoYDv04HeDo

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var manager: HealthManager
    var body: some View {
        VStack{
            LazyVGrid(columns: Array(repeating: GridItem(spacing:15), count: 2)){
                ForEach(manager.activities.sorted(by: {$0.value.id < $1.value.id}), id:\.key) { item in
                    ActivityCardView(activity: item.value)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    StatisticsView()
}
