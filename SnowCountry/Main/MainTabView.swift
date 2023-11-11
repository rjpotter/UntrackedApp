import SwiftUI

struct MainTabView: View {
    let user: User
    
//    init() {
//        // Customize the Tab Bar appearance
//        let appearance = UITabBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = .clear // Set background color to clear
//
//        // Apply the clear appearance to the Tab Bar
//        UITabBar.appearance().standardAppearance = appearance
//
//        // Set background color of the Tab Bar using your UIColor extension
//        appearance.backgroundColor = UIColor.primaryColor
//
//        // Customize the appearance for normal (unselected) tab bar items using your UIColor extension
//        let normalItemAppearance = UITabBarItemAppearance()
//        normalItemAppearance.normal.iconColor = UIColor.secondaryColor
//        normalItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.secondaryColor]
//        appearance.stackedLayoutAppearance = normalItemAppearance
//
//        // Customize the appearance for selected tab bar items using your UIColor extension
//        let selectedItemAppearance = UITabBarItemAppearance()
//        selectedItemAppearance.selected.iconColor = UIColor.fifthColor
//        selectedItemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.fifthColor]
//        appearance.stackedLayoutAppearance = selectedItemAppearance
//
//        // Apply the appearance to the Tab Bar
//        UITabBar.appearance().standardAppearance = appearance
//        UITabBar.appearance().scrollEdgeAppearance = appearance
//    }


    var body: some View {
        ZStack {
            TabView {
                SocialView().tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Social")
                }
                
                MapboxView().tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }

                ProfileView(user: user).tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                
                SafteyView().tabItem {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("Safety")
                }
            }
            .accentColor(.red) // Change the selected tab item color using your custom color
        }
    }
}
/*
struct MainTab_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
*/
