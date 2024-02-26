//
//  ProfileStatistic.swift
//  SnowCountry
//
//  Created by Ryan Potter on 2/12/24.
//

import Foundation
import SwiftUI

extension LocationManager {
    func deleteTrackFile(named fileName: String) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Deleted file:", fileName)
        } catch {
            print("Could not delete file: \(error)")
        }
    }
}

extension Color {
    static let systemBackground = Color(UIColor.secondarySystemBackground)
}

struct ProfileStatistic: Hashable {
    let title: String
    let value: String
}

enum ActiveSheet: Identifiable {
    case friendsList
    case friendRequestsList

    var id: Int {
        hashValue
    }
}

struct ProfileStatisticCard: View {
    let statistic: ProfileStatistic // Assume this is passed correctly when instantiated
    var icon: String? = nil
    var iconColor: Color = .secondary

    var body: some View {
        VStack {
            HStack {
                Image(systemName: iconForStatistic(statistic.title))
                    .foregroundColor(colorForStatistic(statistic.title))
                Text(statistic.title)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            HStack {
                Text(statistic.value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                if let iconName = icon {
                    Image(systemName: iconName)
                        .foregroundColor(iconColor)
                }
            }
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color.secondary.opacity(0.3))
        .cornerRadius(10)
    }

    func iconForStatistic(_ title: String) -> String {
        switch title {
        case "Max Speed":
            return "gauge.with.dots.needle.100percent"
        case "Distance":
            return "map"
        case "Max Elevation", "Min Elevation", "Total Vertical", "Altitude", "Vertical":
            return "mountain.2.circle"
        case "Duration", "Record Time":
            return "clock"
        case "Days":
            return "calendar.circle"
        default:
            return "questionmark.circle"
        }
    }

    func colorForStatistic(_ title: String) -> Color {
        switch title {
        case "Max Speed":
            return .blue
        case "Distance":
            return .green
        case "Max Elevation", "Min Elevation", "Total Vertical", "Altitude", "Vertical":
            return .orange
        case "Duration":
            return .purple
        case "Days", "Record Time":
            return .red
        default:
            return .gray
        }
    }
}

// Custom Label Style
struct IconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .font(.headline)
            configuration.title
        }
        .padding()
        .background(Color.secondary.opacity(0.3))
        .foregroundColor(Color.primary)
        .cornerRadius(10)
    }
}

