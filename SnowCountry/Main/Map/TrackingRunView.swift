import SwiftUI

struct TrackingRunView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            MapboxView()
            
            HStack {
                Button(action: {
                    // Handle button tap action
                    print("Button tapped!")
                }) {
                    Image(systemName: "pause.fill")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .padding()
                }
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(22)
                .padding()
                
                Button(action: {
                    // Handle button tap action
                    print("Button tapped!")
                }) {
                    Image(systemName: "stop.fill")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .padding()
                }
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(22)
                .padding()
            }
        }
    }
}
