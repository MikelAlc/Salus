//
//  ActivityCardView.swift
//  Salus
//
//  Created by MikelAlc on 7/28/25.
//  Based on Tutorial by Jason Dubon:
//  https://youtu.be/7vOF1kGnsmo?si=68NJ4VoYDv04HeDo

import SwiftUI

struct Activity {
    let id: Int
    let title: String
    let subtitle: String
    let imageName: String
    let imageColor: Color
    let amount: String
    
}

struct ActivityCardView: View{
    @State var activity: Activity
    var body: some View{
        ZStack {
            Color(uiColor:.systemGray6)
                .cornerRadius(15)
            VStack{
                HStack(alignment: .top){
                    VStack(alignment: .leading, spacing: 5){
                        Text(activity.title)
                            .font(.system(size: 16))
                        Text(activity.subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: activity.imageName)
                        .foregroundStyle(activity.imageColor)
                }
                .padding()
                
                Text(activity.amount)
                    .font(.system(size: 24))
            }
            .padding()
           
        }
    }
}

#Preview {
    ActivityCardView(activity: Activity(id: 0, title: "Daily Steps", subtitle: "Goal: 10,000", imageName: "figure.walk", imageColor: .green,amount: "3,000"))
}
