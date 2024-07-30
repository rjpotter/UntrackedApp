import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @State var isActive = false

    var body: some View {
        if self.isActive {
            Group {
                if authService.userSession == nil {
                    AuthView()
                } else if let currentUser = authService.currentUser {
                    MainTabView(user: currentUser)
                }
            }
        } else {
            ZStack {
                Color("Base")
                    .ignoresSafeArea()
                Rectangle()
                    .frame(width:750, height: 100)
                    .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.0))
                    .cornerRadius(30)
                    .rotationEffect(.degrees(12))
                    .offset(x: -100, y: -300)
                Rectangle()
                    .frame(width: 750, height: 75)
                    .foregroundColor(Color(red: 76/255, green: 95/255, blue: 104/255))
                    .cornerRadius(30)
                    .rotationEffect(.degrees(12))
                    .offset(x: -100, y: -200)
                Rectangle()
                    .frame(width: 750, height: 50)
                    .foregroundColor(Color(red: 93/255, green: 143/255, blue: 165/255))
                    .cornerRadius(30)
                    .rotationEffect(.degrees(12))
                    .offset(x: -100, y: -125)
                
                Rectangle()
                    .frame(width:750, height: 100)
                    .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.0))
                    .cornerRadius(30)
                    .rotationEffect(.degrees(-12))
                    .offset(x: -100, y: 300)
                Rectangle()
                    .frame(width: 750, height: 75)
                    .foregroundColor(Color(red: 76/255, green: 95/255, blue: 104/255))
                    .cornerRadius(30)
                    .rotationEffect(.degrees(-12))
                    .offset(x: -100, y: 200)
                Rectangle()
                    .frame(width: 750, height: 50)
                    .foregroundColor(Color(red: 93/255, green: 143/255, blue: 165/255))
                    .cornerRadius(30)
                    .rotationEffect(.degrees(-12))
                    .offset(x: -100, y: 125)
                
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(12))
                    .offset(x: 0, y: -275)

                Text("Untracked")
                    .font(Font.custom("Good Times", size:30))
                    .foregroundColor(.white)
                    .padding(.top, -60)
                    .rotationEffect(.degrees(12))
                    .offset(x: -5, y: -137)
                
                Text("Making Backcountry")
                    .font(Font.custom("Good Times", size:20))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(-12))
                    .offset(x: 0, y: 180)
                
                Text("Accessible")
                    .font(Font.custom("Good Times", size:20))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(-12))
                    .offset(x: 0, y: 280)
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
