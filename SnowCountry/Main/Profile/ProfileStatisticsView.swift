//
//  ProfileStatisticsView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 1/10/24.
//

import SwiftUI

struct ProfileStatisticsView: View {
    let rows: [[ProfileStatistic]]
    let lifetimeStats: LifetimeStats
    private let gridItemWidth = UIScreen.main.bounds.width / 2 - 20 // Example width calculation

    var body: some View {
        HStack{
            Text("Lifetime Stats")
                .font(.system(size: 25))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Spacer()
        }
        ForEach(rows, id: \.self) { row in
            LazyVGrid(columns: row.count == 1 ? [GridItem(.flexible())] : [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(row, id: \.self) { stat in
                    if stat.title == "Vertical" {
                        ProfileStatisticCard(
                            statistic: stat,
                            icon: "arrow.down",
                            iconColor: .red
                        )
                        .frame(maxWidth: row.count == 1 ? .infinity : nil)
                    } else {
                        ProfileStatisticCard(statistic: stat)
                            .frame(maxWidth: row.count == 1 ? .infinity : nil)
                    }
                }
            }
        }
    }
    
}
