import SwiftUI
import FirebaseCore
import CoreLocation

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct SnowCountryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var userSettings = UserSettings()
    @StateObject var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(userSettings)
        }
    }
}
