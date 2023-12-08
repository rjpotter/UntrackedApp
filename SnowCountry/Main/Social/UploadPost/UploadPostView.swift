import SwiftUI
import PhotosUI

struct UploadPostView: View {
    let user: User
    @StateObject var viewModel = UploadPostViewModel()
    @State private var caption = ""
    @State private var imageSelectorShown = false
    @Environment(\.presentationMode) var presentationmode
    
    var backButton: some View {
        Button {
            caption = ""
            viewModel.selectedImage = nil
            viewModel.postImage = nil
            presentationmode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "arrow.left")
                .foregroundColor(.cyan)
                .imageScale(.large)
                .padding(.trailing, 8)
        }
    }
    
    var uploadButton: some View {
        Button {
            Task {
                try await viewModel.uploadPost(caption: caption)
                print(caption)
                
                caption = ""
                
                viewModel.selectedImage = nil
                viewModel.postImage = nil
               
            }
        } label: {
            Text("Share")
                .foregroundColor(.cyan)
                .padding(.trailing, 8)
        }
    }
    
    var body: some View {
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
            } else {
                Button {
                    imageSelectorShown.toggle()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .foregroundColor(.cyan)
                    
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    
                    
                    Text("Choose Image")
                        .foregroundColor(.cyan)
                    
                }
                
                TextField("Enter caption...", text: $caption, axis: .vertical)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 10)
                    .background(Color("Background"))
                    .offset(y: 20)
            }
        }
        .padding(10)
        .navigationTitle("Upload Post")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton,
                            trailing: uploadButton)
        .photosPicker(isPresented: $imageSelectorShown, selection: $viewModel.selectedImage)
        
        
        
        
        
//        VStack {
//            VStack {
//                HStack{
//
//
//                    Spacer()
//                    Text("Create a new post")
//                        .font(.headline)
//                    Spacer()
//
//                }
//                VStack(){
//                    VStack {
//
//
//                    }
//                    .navigationBarBackButtonHidden(true)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .onAppear{ imageSelectorShown.toggle() }
//                }
//                .background(Color("Base").opacity(0.5))
//            }
//            .background(Color("Background").opacity(0.5))
//            HStack{
//
//                TextField("Enter caption...", text: $caption, axis: .vertical)
//                    .keyboardType(.default)
//
//            }
//            .padding()
//            .background(Color("Background"))
//            .frame( height: 100)
//
//        }
    }
}
