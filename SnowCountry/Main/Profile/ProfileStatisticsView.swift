//
//  ProfileStatisticsView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 1/10/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileStatisticsView: View {
    let user: User
    @EnvironmentObject var userSettings: UserSettings
    let rows: [[ProfileStatistic]]
    private let gridItemWidth = UIScreen.main.bounds.width / 2 - 20
    @ObservedObject var profileViewModel: ProfileViewModel

    var body: some View {
        VStack {
            HStack {
                Text("Lifetime Stats")
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                if isCurrentUserProfile() {
                    Button(action: {
                        profileViewModel.updateAndFetchLifetimeStats {
                            // This completion block is left empty intentionally.
                            // Add any actions you'd like to perform after the stats have been updated.
                        }
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.circle")
                            .font(.system(size: 25))
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
            }
            
            ForEach(rows, id: \.self) { row in
                LazyVGrid(columns: row.count == 1 ? [GridItem(.flexible())] : [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(row, id: \.self) { stat in
                        VStack {
                            let statValue: String = determineStatValue(for: stat.title, using: profileViewModel.lifetimeStats)
                            
                            ProfileStatisticCard(
                                statistic: ProfileStatistic(title: stat.title, value: statValue)
                            )
                            .frame(maxWidth: row.count == 1 ? .infinity : nil)
                        }
                    }
                }
            }
        }
        .onAppear {
            if !isCurrentUserProfile() {
                profileViewModel.fetchLifetimeStatsFromFirebase {
                    // This completion block is left empty intentionally.
                    // Add any actions you'd like to perform after the stats have been fetched.
                }
            }
        }
    }
    
    private func isCurrentUserProfile() -> Bool {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return false }
        return currentUserID == user.id
    }
    
    private func determineStatValue(for title: String, using stats: LifetimeStats) -> String {
        switch title {
        case "Days":
            return "\(stats.totalDays)"
        case "Vertical":
            return profileViewModel.formatElevation(stats.totalDownVertical)
        case "Distance":
            return profileViewModel.formatDistance(stats.totalDownDistance)
        case "Max Speed":
            return profileViewModel.formatSpeed(stats.topSpeed)
        case "Record Time":
            return profileViewModel.formattedTime(time: stats.totalDuration)
        default:
            return "N/A"
        }
    }
}
