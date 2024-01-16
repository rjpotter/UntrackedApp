//
//  ProfileStatisticsView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 1/10/24.
//

import SwiftUI

struct ProfileStatisticsView: View {
    let rows: [[Statistic]]
    let lifetimeStats: LifetimeStats
    private let gridItemWidth = UIScreen.main.bounds.width / 2 - 20 // Example width calculation

    var body: some View {
        ForEach(rows, id: \.self) { row in
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(row, id: \.self) { stat in
                    StatisticCard(
                        statistic: stat,
                        icon: stat.title == "Vertical" ? "arrow.down" : nil,
                        iconColor: stat.title == "Vertical" ? .red : .black
                    )
                    .frame(maxWidth: gridItemWidth) // Consistent width for all cards
                }
            }
        }
    }
}
