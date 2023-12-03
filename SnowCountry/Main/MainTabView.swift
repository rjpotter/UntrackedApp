import SwiftUI

struct MainTabView: View {
    @State var isMetric: Bool = false
    let user: User
    
    var body: some View {
        ZStack {
            TabView {
                SocialView(user: user).tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Social")
                }
                
                MapboxView().tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
                
                RecordView(isMetric: $isMetric).tabItem {
                    Image(systemName: "record.circle")
                    Text("Record")
                }

                ProfileView(user: user, isMetric: $isMetric).tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                
                SafetyView().tabItem {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("Safety")
                }
            }
            .accentColor(.secondaryColor)
        }
    }
}

