import SwiftUI

struct MainTabView: View {
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
                
                RecordView().tabItem {
                    Image(systemName: "record.circle.fill")
                    Text("Record")
                }

                ProfileView(user: user).tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                
                SafetyView().tabItem {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("Safety")
                }
            }
            .accentColor(.primaryColor)
        }
    }
}

