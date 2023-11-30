import SwiftUI
import MapKit

// Custom struct for statistics
struct Statistic: Hashable {
    let title: String
    let value: String
}

struct RecordView: View {
    @State private var tracking = false
    @ObservedObject var locationManager = LocationManager()
    @State private var trackViewMap = MKMapView()
    @State private var maxSpeed: Double = 0.0
    @State private var skiDistance: Double = 0.0
    @State private var skiVertical: Double = 0.0
    @State private var currentAltitude: Double = 0.0
    @State private var duration: Double = 0.0

    // Statistics data
    private var statistics: [Statistic] {
        return [
            Statistic(title: "Max Speed", value: "\(maxSpeed) km/h"),
            Statistic(title: "Ski Distance", value: "\(skiDistance) km"),
            Statistic(title: "Ski Vertical", value: "\(skiVertical) m"),
            Statistic(title: "Current Altitude", value: "\(currentAltitude) m"),
            Statistic(title: "Duration", value: "\(duration) min")
        ]
    }

    // Calculate rows for grid
    private var rows: [[Statistic]] {
        var rows: [[Statistic]] = []
        var currentRow: [Statistic] = []

        for statistic in statistics {
            currentRow.append(statistic)
            if currentRow.count == 2 || statistic == statistics.last! {
                rows.append(currentRow)
                currentRow = []
            }
        }

        return rows
    }

    var body: some View {
        VStack {
            ForEach(rows, id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { item in
                        StatisticsBox(statistic: item)
                            .frame(maxWidth: .infinity) // Ensure each box takes up maximum available space
                    }
                }
            }

            Spacer()
            
            TrackViewMap(trackViewMap: $trackViewMap, locations: locationManager.locations)
                .frame(height: 300) // Set a fixed height for the map view
                .listRowInsets(EdgeInsets()) // Make the map view full-width

            // Start/Stop Recording Button
            Button(action: {
                self.tracking.toggle()
                if self.tracking {
                    self.locationManager.startTracking()
                } else {
                    self.locationManager.stopTracking()
                }
            }) {
                Text(tracking ? "Stop Recording" : "Start Recording")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

struct StatisticsBox: View {
    var statistic: Statistic

    var body: some View {
        VStack {
            Text(statistic.title)
                .font(.headline)
            Spacer()
            Text(statistic.value)
                .font(.body)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}
