import SwiftUI
import PhotosUI

struct UploadPostView: View {
    let user: User
    @StateObject var viewModel = UploadPostViewModel()
    @State private var caption = ""
    
    @State private var imageSelectorShown = false
    @Environment(\.dismiss) var dismiss
    //    @Binding var tabIndex: Int
    
    var body: some View {
        VStack{
            VStack {
                Text("SnowCountry")
                    .font(Font.custom("Good Times", size:30))
                HStack{
                    Button {
                        caption = ""
                        
                        viewModel.selectedImage = nil
                        viewModel.postImage = nil
                        dismiss()
                                        
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.cyan)
                            .imageScale(.large)
                            .padding(.trailing, 8)
                    }
                    
                    Spacer()
                    Text("Create a new post")
                        .font(.headline)
                    Spacer()
                    Button {
                        Task {
                            try await viewModel.uploadPost(caption: caption)
                            print(caption)
                            
                            caption = ""
                            
                            viewModel.selectedImage = nil
                            viewModel.postImage = nil
                            dismiss()
                           
                        }
                    } label: {
                        Text("Share")
                            .foregroundColor(.cyan)
                            .padding(.trailing, 8)
                    }
                }
                VStack(){
                    VStack {
                        if let image = viewModel.postImage {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            
                            
                            Button {
                                imageSelectorShown.toggle()
                            } label: {
                                Text("Change Image")
                                    .foregroundColor(.cyan)
                            }
                        }
                        
                        else{
                            Button(action: {
                                imageSelectorShown.toggle()
                                
                                
                            }){
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .foregroundColor(.cyan)
                                
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                
                                
                                Text("Choose Image")
                                    .foregroundColor(.cyan)
                                
                            }
                        }
                        
                    }
                    .navigationBarBackButtonHidden(true)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear{ imageSelectorShown.toggle() }
                    .photosPicker(isPresented: $imageSelectorShown, selection: $viewModel.selectedImage)
                }
                .background(Color("Base").opacity(0.5))
            }
            .background(Color("Background").opacity(0.5))
            HStack{
                
                TextField("Enter caption...", text: $caption, axis: .vertical)
                    .keyboardType(.default)
                   
            }
            .padding()
            .background(Color("Background"))
            .frame( height: 100)
           
        }
        .background(Color("Background").opacity(0.5))
    }
}
