//
//  GPXParser.swift
//  SnowCountry
//
//  Created by Ryan Potter on 1/6/24.
//

import CoreLocation

class GPXParser {
    static func parseGPX(_ gpxString: String) -> [CLLocation] {
        let xmlParser = XMLParser(data: Data(gpxString.utf8))
        let gpxParserDelegate = GPXParserDelegate()
        xmlParser.delegate = gpxParserDelegate
        
        xmlParser.parse()
        return gpxParserDelegate.foundLocations
    }
    
    class GPXParserDelegate: NSObject, XMLParserDelegate {
        var foundLocations: [CLLocation] = []
        private var currentLatitude: Double?
        private var currentLongitude: Double?
        private var currentElevation: Double?
        private var currentTimestamp: Date?
        private var currentElementValue: String?

        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            if elementName == "trkpt" {
                if let latStr = attributeDict["lat"], let lonStr = attributeDict["lon"], let lat = Double(latStr), let lon = Double(lonStr) {
                    currentLatitude = lat
                    currentLongitude = lon
                }
            }
            currentElementValue = nil
        }

        func parser(_ parser: XMLParser, foundCharacters string: String) {
            if currentElementValue == nil {
                currentElementValue = string
            } else {
                currentElementValue? += string
            }
        }

        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            switch elementName {
            case "ele":
                if let elevationString = currentElementValue?.trimmingCharacters(in: .whitespacesAndNewlines),
                   let elevation = Double(elevationString) {
                    currentElevation = elevation
                }
            case "time":
                if let timeString = currentElementValue?.trimmingCharacters(in: .whitespacesAndNewlines),
                   let time = parseDate(timeString) {
                    currentTimestamp = time
                }
            case "trkpt":
                if let lat = currentLatitude, let lon = currentLongitude, let elevation = currentElevation, let timestamp = currentTimestamp {
                    let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), altitude: elevation, horizontalAccuracy: kCLLocationAccuracyBest, verticalAccuracy: kCLLocationAccuracyBest, timestamp: timestamp)
                    foundLocations.append(location)
                    currentLatitude = nil
                    currentLongitude = nil
                    currentElevation = nil
                    currentTimestamp = nil
                }
            default:
                break
            }
            currentElementValue = nil
        }

        private func parseDate(_ dateString: String) -> Date? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            return dateFormatter.date(from: dateString)
        }
    }
}
