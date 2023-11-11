import SwiftUI

extension Color {
    static let primaryColor = Color("OrangeColor")
    static let thirdColor = Color("GrayColor")
    static let fourthColor = Color("TanColor")
    static let fifthblueColor = Color("LightBlueColor")
    static let secondaryColor = Color("DarkCyanColor")
}

extension UIColor {
    static let primaryColor = UIColor(named: "OrangeColor") ?? UIColor.orange
    static let thirdColor = UIColor(named: "GrayColor") ?? UIColor.gray
    static let fourthColor = UIColor(named: "TanColor") ?? UIColor.brown
    static let fifthColor = UIColor(named: "LightBlueColor") ?? UIColor.blue
    static let secondaryColor = UIColor(named: "DarkCyanColor") ?? UIColor.cyan
}
