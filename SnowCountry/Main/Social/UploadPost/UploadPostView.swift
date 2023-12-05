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
        VStack {
            // Tool bar
            HStack {
                Button {
                    caption = ""
                    viewModel.selectedImage = nil
                    viewModel.postImage = nil
                    dismiss()
//                    tabIndex = 0
                } label: {
                    Text("Cancel")
                }
                
                Spacer()
                
                Text("Create a new post")
                
                Spacer()
                
                Button {
                    Task {
                        try await viewModel.uploadPost(caption: caption)
                        print(caption)
                        caption = ""
                        viewModel.selectedImage = nil
                        viewModel.postImage = nil
                        dismiss()
//                        tabIndex = 0
                    }
                } label: {
                    Text("Upload")
                }
            }
            .padding(.horizontal)
            
            HStack {
                if let image = viewModel.postImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                }
                
                TextField("Enter caption...", text: $caption, axis: .vertical)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{ imageSelectorShown.toggle() }
        .photosPicker(isPresented: $imageSelectorShown, selection: $viewModel.selectedImage)
    }
}
