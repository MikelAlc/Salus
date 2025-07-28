//
//  StatisticsView.swift
//  Salus
//
//  Created by MikelAlc on 7/28/25.
//

import SwiftUI

struct StatisticsView: View {
    var body: some View {
        VStack{
            LazyVGrid(columns: Array(repeating: GridItem(spacing:15), count: 2)){
                ActivityCardView()
                ActivityCardView()
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    StatisticsView()
}
