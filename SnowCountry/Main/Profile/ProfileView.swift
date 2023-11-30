import SwiftUI

struct ProfileView: View {
    let user: User
    @State private var showEditProfile = false
    @State var isDarkMode = false
    
    var body: some View {
        NavigationView {
            List {
                ZStack(alignment: .leading) {
                    // banner image, i want to change it so it can be edited like the profile image
                    Image("testBannerImage")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                    
                    // profile image
                    ProfileImageView(user: user)
                    //.offset(x:80, y: -150)
                        .offset(x:60, y: 60)
                    
                    // username
                    HStack() {
                        Text(user.username)
                        
                            .font(.system(size: 25))
                            .fontWeight(.semibold)
                        
                        //.offset(x:80, y: -155)
                            .offset(x:65,  y: 170)
                        
                        
                        
                    }
                    //DARK MODE BUTTON
                    HStack(){
                        Button(action: {
                            isDarkMode.toggle()
                        }) {
                            Image(systemName: isDarkMode ? "moon.fill" : "moon")
                                .resizable()
                                .frame(width: 30, height: 30, alignment: .trailing)
                                .foregroundColor(isDarkMode ? .blue : .blue)
                                .clipped().buttonStyle(BorderlessButtonStyle())
                                .fixedSize()
                                .padding(.leading, 50)
                            
                            
                            
                            
                            
                        } .buttonStyle(ClippedButtonStyle())
                        //.offset( x: 200, y: -205)
                            .offset( x: 185,   y: 217)
                    }
                    
                    
                    
                    
                    
                    // EDIT PROFILE BUTTON
                    VStack(alignment: .leading) {
                        Button(action: {
                            showEditProfile.toggle()
                        }) {
                            HStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 150, height: 50)
                                    .cornerRadius(8)
                                    .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                                    .overlay(
                                        Text("Edit Profile")
                                            .font(.system(size: 15))
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.black)
                                    )
                                
                            }
                            .frame(width: 100, height: 60)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .offset(x: -25, y: 217)
                    .offset(x: 100)
                    .padding()
                }
                .padding(.top, -12)
                .padding(.bottom, 150)
                
                // this is where the runs will be uploaded
                Section(header: Text("RUN HISTORY").fontWeight(.bold)) {
                    Text("Run History")
                    Text("Run on 9/28")
                    Text("Run on 9/27")
                    Text("Run on 9/28")
                    Text("Run on 9/27")
                    Text("Run on 9/28")
                    Text("Run on 9/27")
                    Text("Run on 9/28")
                    Text("Run on 9/27")
                    Text("Run on 9/28")
                    Text("Run on 9/27")
                    Text("Run on 9/28")
                    Text("Run on 9/27")
                    Text("Run on 9/28")
                    Text("Run on 9/27")
                    Text("Run on 9/28")
                    Text("Run on 9/27")
                    Text("Run on 9/28")
                    Text("Run on 9/27")
                }
                
                .background(Color(UIColor.systemBackground))
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .navigationTitle("User Profile")
                .fullScreenCover(isPresented: $showEditProfile) {
                    EditProfileView(user: user)
                    
                }
            }
            .padding(.leading, -20)
            .padding(.trailing, -20)
        }
    }
}

// added this function so the buttons can only be pressed within there shape
struct ClippedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
        
    }
}


