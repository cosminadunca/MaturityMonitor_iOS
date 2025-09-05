import SwiftUI
import Mixpanel

struct AddChildStepOneView: View {
    
    @Environment(\.presentationMode) private var presentationMode // Back button
    @ObservedObject var childDetails = ChildDetailsModel()
    
    @State private var showErrorMessage: Bool = false
    @State private var errorMessage: String = ""
    @State private var navigateToNextView: Bool = false

    // Mixpanel variables
    @State private var viewStartTime: Date = Date()
    @State private var calendarTapCount = 0
    @State private var numberOfStepsBack: Double = 0
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack {
                    Spacer()
                    SimpleCustomTextTitle(title: "Child's details")
                    Spacer()
                    SimpleCustomTextField(placeholder: "Name", text: $childDetails.name, viewName: "Add Child Step One")
                    SimpleCustomTextField(placeholder: "Surname", text: $childDetails.surname, viewName: "Add Child Step One")
                    Spacer()
                    Text("Please enter the date of birth below")
                        .font(Font.custom("Inter", size: 15))
                        .foregroundColor(.black)
                    CustomDateTextField(
                        placeholder: "DD/MM/YYYY",
                        dateText: $childDetails.dateOfBirth,
                        viewName: "Add Child Step One",
                        calendarTapCount: $calendarTapCount
                    )
                    Spacer()
                    Button(action: validateFields) {
                        CustomButton(
                            title: "Next step",
                            backgroundColor: Color(.buttonGreyLight),
                            textColor: .black
                        ).padding(.bottom, 60)
                    }
                    
                    // NavigationLink to next view
                    NavigationLink(destination: AddChildStepTwoView(childDetails: childDetails, numberOfStepsBack: $numberOfStepsBack), isActive: $navigateToNextView) {
                        EmptyView()
                    }
                    
                    if showErrorMessage {
                        ErrorCustomText(title: errorMessage)
                    }
                    ProgressBar(progressMultiplier: 1)
                }
                .onTapGesture {
                    hideKeyboard() // Hide keyboard when tapping outside
                }
                .onAppear {
                    viewStartTime = Date()
                }
                .onDisappear {
                    trackViewTime()
                    Mixpanel.mainInstance().track(event: "MIX Calendar Tap Count in Add Child Step One View", properties: [
                            "calendar_tap_count": calendarTapCount
                        ])
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(.black)
                                    .font(.font18)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    // Mixpanel tracking
    private func trackViewTime() {
        let timeSpent = Date().timeIntervalSince(viewStartTime)
        Mixpanel.mainInstance().track(event: "MIX Add Child Step One View Time", properties: ["time_spent": timeSpent])
    }

    private func validateFields() {
        // Track Mixpanel event for attempting validation
        Mixpanel.mainInstance().track(event: "MIX Next Step Button Attempted in Add Child Step One View", properties: [
            "name": childDetails.name,
            "surname": childDetails.surname,
            "dateOfBirth": childDetails.dateOfBirth
        ])
        
        if childDetails.name.isEmpty || childDetails.surname.isEmpty || childDetails.dateOfBirth.isEmpty {
            errorMessage = "All fields must be completed!"
            showErrorMessage = true
            
            // Track failure event for missing fields
            Mixpanel.mainInstance().track(event: "MIX Validation Failed - Missing Fields in Add Child Step One View", properties: [
                "name_missing": childDetails.name.isEmpty,
                "surname_missing": childDetails.surname.isEmpty,
                "dob_missing": childDetails.dateOfBirth.isEmpty
            ])
            return
        }

        // Ensure the date is in the expected format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy" // Update to match the expected input format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Use a fixed locale to avoid issues with date parsing

        if let date = dateFormatter.date(from: childDetails.dateOfBirth) {
            // Check if the date is not in the future
            if date <= Date() {
                showErrorMessage = false
                navigateToNextView = true
                
                // Track success event
                Mixpanel.mainInstance().track(event: "MIX Validation Succeeded in Add Child Step One View", properties: [
                    "name": childDetails.name,
                    "surname": childDetails.surname,
                    "dateOfBirth": childDetails.dateOfBirth
                ])
            } else {
                errorMessage = "Date of birth cannot be in the future!"
                showErrorMessage = true
                
                // Track failure event for future DOB
                Mixpanel.mainInstance().track(event: "MIX Validation Failed - DOB in Future in Add Child Step One View", properties: [
                    "dateOfBirth": childDetails.dateOfBirth
                ])
            }
        } else {
            errorMessage = "Please enter a valid date of birth!"
            showErrorMessage = true
            
            // Track failure event for invalid DOB format
            Mixpanel.mainInstance().track(event: "MIX Validation Failed - Invalid DOB Format in Add Child Step One View", properties: [
                "dateOfBirth": childDetails.dateOfBirth
            ])
        }
    }

}

#Preview {
    AddChildStepOneView()
}
