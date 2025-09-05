// AddChildStepTwo View comments and messages done - needs testing

import SwiftUI
import Mixpanel

struct AddChildStepTwoView: View {
    
    @Environment(\.presentationMode) private var presentationMode // Back button
    @ObservedObject var childDetails: ChildDetailsModel
    
    @State private var showErrorMessage: Bool = false
    @State private var navigateToNextView: Bool = false
    
    // For adding an image to the child account in AWS Amplify
//    @State private var selectedImage: UIImage?
//    @State private var isImagePickerPresented = false
    
    // Mixpanel variables
    @State private var viewStartTime: Date = Date()
    @Binding var numberOfStepsBack: Double
    
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
                CustomCheckbox(options: [Gender.male, Gender.female],
                               selectedOption: $childDetails.gender,
                               font: Font.custom("Inter", size: 18),
                               trackingEvent: "MIX Gender Selected in Add Child Step Two View")
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
                    // Increment the number of steps back
                    numberOfStepsBack += 1
                    
                    // Dismiss the current view
                    presentationMode.wrappedValue.dismiss()
                }) {
                    CustomButton(
                        title: "Previous step",
                        backgroundColor: Color(.buttonGreyLight),
                        textColor: .black
                    )
                }

                Button(action: {
                    validateFields()
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
        .onAppear {
            viewStartTime = Date()
        }
        .onDisappear {
            trackViewTime()
        }
        .onTapGesture {
            hideKeyboard() // Hide keyboard when tapping outside
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        hideKeyboard()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarBackButtonHidden(true)
        
        // NavigationLink to next view (AddChildStepThreeView)
        NavigationLink(destination: AddChildStepThreeView(childDetails: childDetails, numberOfStepsBack: $numberOfStepsBack), isActive: $navigateToNextView) {
            EmptyView()
        }
    }
    
    // Mixpanel
    private func trackViewTime() {
        let timeSpent = Date().timeIntervalSince(viewStartTime)
        Mixpanel.mainInstance().track(event: "MIX Add Child Step Two View Time", properties: ["time_spent": timeSpent])
    }
    
    private func validateFields() {
        // Track Mixpanel event for attempting validation
        let genderValue = childDetails.gender?.rawValue ?? "None" // Use raw value or fallback to "None"
        Mixpanel.mainInstance().track(event: "MIX Next Step Button Attempted in Add Child Step Two View", properties: [
            "gender": genderValue
        ])
        
        // Check if gender is selected
        if childDetails.gender == nil {
            showErrorMessage = true
            
            // Track failure event for missing gender selection
            Mixpanel.mainInstance().track(event: "MIX Validation Failed - Missing Gender in Add Child Step Two View")
            return
        }
        
        // If gender is selected, proceed to the next view
        showErrorMessage = false
        navigateToNextView = true
        
        // Track success event
        Mixpanel.mainInstance().track(event: "MIX Validation Succeeded in Add Child Step Two View", properties: [
            "gender": genderValue // Use the same gender value
        ])
    }
}

#Preview {
    AddChildStepTwoView(childDetails: ChildDetailsModel(), numberOfStepsBack: .constant(0))
}
