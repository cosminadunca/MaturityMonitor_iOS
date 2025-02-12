// AddChildStepTwo View comments and messages done - needs testing

import SwiftUI

struct AddChildStepTwoView: View {
    
    @Environment(\.presentationMode) private var presentationMode // Back button
    @ObservedObject var childDetails: ChildDetailsModel
    
    @State private var showErrorMessage: Bool = false
    @State private var navigateToNextView: Bool = false
    
    // For adding an image to the child account in AWS Amplify
//    @State private var selectedImage: UIImage?
//    @State private var isImagePickerPresented = false
    
    var body: some View {
        VStack {
            Spacer()
            Spacer()
            SimpleCustomTextTitle(title: "Child's details")
            Spacer()
            VStack {
                Text("Choose one of the following")
                    .font(Font.custom("Inter", size: 15))
                    .foregroundColor(.black)
                CustomCheckbox(options: [Gender.male, Gender.female], selectedOption: $childDetails.gender, font: Font.custom("Inter", size: 18))
                    .padding(25)
            }
//            VStack {
//                if let image = selectedImage {
//                    Image(uiImage: image)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 200, height: 200)
//                        .cornerRadius(15)
//                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
//                        .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
//                        )
//                } else {
//                    Text("Select an image if you would like to attach it to the child's profile (Optional): ")
//                        .font(Font.custom("Inter", size: 15))
//                        .foregroundColor(.black)
//                        .padding(.bottom, 10)
//                }
//                Button(action: {
//                    isImagePickerPresented = true
//                }) {
//                    CustomButton(
//                        title: "Select",
//                        backgroundColor: Color("ButtonPurpleLight"),
//                        textColor: .white
//                    ).padding(.top, 15)
//                }
//                .sheet(isPresented: $isImagePickerPresented) {
//                    ImagePicker(image: $selectedImage)
//                }
//            }
//            .padding()
            
            Spacer()
            Spacer()
            Spacer()

            // Buttons
            HStack(spacing: 10) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    CustomButton(
                        title: "Previous step",
                        backgroundColor: Color(.buttonGreyLight),
                        textColor: .black
                    )
                }

                // NavigationLink for the next view
                NavigationLink(destination: AddChildStepThreeView(childDetails: childDetails), isActive: $navigateToNextView) {
                    EmptyView()
                }

                Button(action: {
                    if childDetails.gender == nil {
                        // If no gender is selected, show an error message
                        showErrorMessage = true
                    } else {
                        // If a gender is selected, navigate to the next view
                        showErrorMessage = false
                        // Save the selected image into the model
//                        if let selectedImage = selectedImage {
//                            childDetails.image = selectedImage
//                        } else {
//                            childDetails.image = nil
//                        }
                        navigateToNextView = true
                    }
                }) {
                    CustomButton(
                        title: "Next step",
                        backgroundColor: Color(.buttonGreyLight),
                        textColor: .black
                    )
                }
            }
            .padding(.bottom, 60)
            
            if showErrorMessage {
                ErrorCustomText(title: "Please select a gender!")
            }
            ProgressBar(progressMultiplier: 2)
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    AddChildStepTwoView(childDetails: ChildDetailsModel())
}
