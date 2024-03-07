//
//  ProfileViewModel.swift
//  SnowCountry
//
//  Created by Ryan Potter on 2/23/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    @Published var lifetimeStats: LifetimeStats = LifetimeStats()
    private var locationManager: LocationManager
    private var userSettings: UserSettings
    private var trackFiles: [String] = []
    let user: User
    
    init(user: User, locationManager: LocationManager, userSettings: UserSettings) {
        self.user = user
        self.locationManager = locationManager
        self.userSettings = userSettings
    }
    
    func updateAndFetchLifetimeStats(completion: @escaping () -> Void) {
        self.updateLifetimeStats() // Calculate stats from local data

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(self.user.id)

        // Prepare the stats data for Firebase update
        let statsData: [String: Any] = [
            "totalDays": self.lifetimeStats.totalDays,
            "totalDownVertical": self.lifetimeStats.totalDownVertical,
            "totalDownDistance": self.lifetimeStats.totalDownDistance,
            "topSpeed": self.lifetimeStats.topSpeed,
            "totalDuration": self.lifetimeStats.totalDuration
        ]

        // Update and fetch from Firebase
        userRef.updateData(["lifetimeStats": statsData]) { [weak self] error in
            if let error = error {
                print("Error updating document: \(error)")
                completion()
            } else {
                print("Document successfully updated")
                self?.fetchLifetimeStatsFromFirebase {
                    completion()
                }
            }
        }
    }

    func fetchLifetimeStatsFromFirebase(completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id)
        
        userRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                if let data = document.data()?["lifetimeStats"] as? [String: Any] {
                    DispatchQueue.main.async {
                        // Assuming lifetimeStats properties like totalDays, totalDownVertical, etc., are numerical
                        self?.lifetimeStats.totalDays = data["totalDays"] as? Int ?? 0
                        self?.lifetimeStats.totalDownVertical = data["totalDownVertical"] as? Double ?? 0.0
                        self?.lifetimeStats.totalDownDistance = data["totalDownDistance"] as? Double ?? 0.0
                        self?.lifetimeStats.topSpeed = data["topSpeed"] as? Double ?? 0.0
                        self?.lifetimeStats.totalDuration = data["totalDuration"] as? TimeInterval ?? 0.0
                        completion()
                    }

                } else {
                    print("Document exists, but lifetimeStats not found or not in expected format")
                    completion()
                }
            } else {
                print("Document does not exist or failed to fetch lifetime stats: \(error?.localizedDescription ?? "Unknown error")")
                completion()
            }
        }
    }

    
    func loadTrackFiles() {
        let trackFilenames = locationManager.getTrackFiles().sorted(by: { $1 > $0 })
        print("Loaded track files: \(trackFilenames)")
        self.trackFiles = trackFilenames
    }
    
    func updateLifetimeStats() {
        var lifetimeMaxSpeed = 0.0
        var uniqueRecordingDates: Set<Date> = []
        loadTrackFiles()
        
        // Reset lifetimeStats to zero before recalculating
        lifetimeStats = LifetimeStats()
        
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let calendar = Calendar.current
        
        for fileName in trackFiles {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            guard let fileContents = try? String(contentsOf: fileURL) else {
                continue
            }
            let locations = GPXParser.parseGPX(fileContents)
            
            if let firstLocation = locations.first {
                let date = calendar.startOfDay(for: firstLocation.timestamp)
                uniqueRecordingDates.insert(date)
            }
            
            let distance = calculateTotalDownDistance(locations: locations, isMetric: userSettings.isMetric)
            let maxElevation = calculateMaxElevation(locations: locations, isMetric: userSettings.isMetric)
            let duration = calculateDuration(locations: locations)
            let maxSpeed = calculateMaxSpeed(locations: locations, isMetric: userSettings.isMetric)
            let vertical = calculateTotalElevationLoss(locations: locations, isMetric: userSettings.isMetric)
            
            // Update lifetimeStats properties
            // For some reason, this is opposite of everything else for isMetric... so I put temporary fix
            lifetimeStats.totalDownDistance += (userSettings.isMetric ? distance : distance * 1.609)
            lifetimeStats.maxElevation = max(lifetimeStats.maxElevation, maxElevation)
            lifetimeStats.totalDuration += duration
            // For some reason, this is opposite of everything else for isMetric... so I put temporary fix
            lifetimeStats.totalDownVertical += (userSettings.isMetric ? vertical : vertical / 3.28084)
            lifetimeMaxSpeed = max(lifetimeMaxSpeed, maxSpeed)
        }
        
        lifetimeStats.topSpeed = userSettings.isMetric ? lifetimeMaxSpeed : lifetimeMaxSpeed * 1.609
        
        // Update the total number of unique recording days
        lifetimeStats.totalDays = uniqueRecordingDates.count
    }

    func convertSpeed(_ speed: Double, toMetric: Bool) -> Double {
        if !toMetric {
            return speed // Assuming speed is already in metric units
        } else {
            // Convert km/h to mph for imperial units
            return speed * 0.621371
        }
    }
    
    func formattedTime(time: TimeInterval) -> String {
        let seconds = Int(time)
        
        let days = seconds / 86400 // 86400 seconds in a day
        let hours = (seconds % 86400) / 3600 // Remaining hours after calculating days
        
        var timeString = ""
        
        if days > 0 {
            timeString += "\(days) day\(days == 1 ? "" : "s")"
        }
        
        if hours > 0 {
            if !timeString.isEmpty {
                timeString += " "
            }
            timeString += "\(hours) hr"
        }
        
        return timeString.isEmpty ? "0 hr" : timeString
    }
    
    func formatNumber(_ value: Double, isMetric: Bool, unit: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1

        if isMetric {
            formatter.groupingSeparator = "."
            formatter.decimalSeparator = ","
        } else {
            formatter.groupingSeparator = ","
            formatter.decimalSeparator = "."
        }

        let number = NSNumber(value: value)
        let formattedValue = formatter.string(from: number) ?? "\(value)"
        return "\(formattedValue) \(unit)"
    }
    
    func formatDistance(_ distance: Double) -> String {
        let unit = userSettings.isMetric ? "km" : "mi"
        let convertedDistance = userSettings.isMetric ? distance : distance * 0.621371 // Convert km to miles if needed
        return formatNumber(convertedDistance, isMetric: userSettings.isMetric, unit: unit)
    }

    func formatSpeed(_ speed: Double) -> String {
        let unit = userSettings.isMetric ? "km/h" : "mph"
        let convertedSpeed = userSettings.isMetric ? speed : speed * 0.621371 // Convert km/h to mph if needed
        return formatNumber(convertedSpeed, isMetric: userSettings.isMetric, unit: unit)
    }

    func formatElevation(_ elevation: Double) -> String {
        let unit = userSettings.isMetric ? "m" : "ft"
        let convertedElevation = userSettings.isMetric ? elevation : elevation * 3.28084 // Convert meters to feet if needed
        return formatNumber(convertedElevation, isMetric: userSettings.isMetric, unit: unit)
    }
}
