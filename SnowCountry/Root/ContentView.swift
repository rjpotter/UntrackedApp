import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    @State var isActive = false
    
    var body: some View {
        if self.isActive {
            Group {
                if viewModel.userSession == nil {
                    LoginView()
                } else if let currentUser = viewModel.currentUser {
                    MainTabView(user: currentUser)
                }
            }
        } else {
            ZStack {
                Rectangle()
                    .fill(Color(red: 0.8, green: 0.4, blue: 0.0))
                    .background(Color(red: 0.8, green: 0.4, blue: 0.0))
                VStack() {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400, height: 400)
                    
                    Text("SnowCountry")
                        .font(.custom("Good Times", size:30))
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation{
                        self.isActive = true
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
