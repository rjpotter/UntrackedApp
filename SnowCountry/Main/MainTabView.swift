import SwiftUI

struct MainTabView: View {
    @State var isMetric: Bool = false
    @State private var selectedIndex = 0
    let user: User
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            SocialView(user: user)
                .onAppear {
                    selectedIndex = 0
                }
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Social")
                }.tag(0)
            
            MapBoxRouteView()
                .onAppear {
                    selectedIndex = 1
                }
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }.tag(1)
            
            RecordView(isMetric: $isMetric)
                .onAppear {
                    selectedIndex = 2
                }
                .tabItem {
                    Image(systemName: "record.circle")
                    Text("Record")
                }.tag(2)

            ProfileView(user: user, isMetric: $isMetric)
                .onAppear {
                    selectedIndex = 3
                }
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }.tag(3)
            
            SafetyView()
                .onAppear {
                    selectedIndex = 4
                }
                .tabItem {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("Safety")
                }.tag(4)
        }
        .accentColor(.cyan)
    }
}

