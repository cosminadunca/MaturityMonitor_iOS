// AddChildStepOne View comments and messages done - needs testing

import SwiftUI

struct AddChildStepOneView: View {
    
    @Environment(\.presentationMode) private var presentationMode // Back button
    @ObservedObject var childDetails = ChildDetailsModel()
    
    @State private var showErrorMessage: Bool = false
    @State private var errorMessage: String = ""
    @State private var navigateToNextView: Bool = false
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack {
                    Spacer()
                    SimpleCustomTextTitle(title: "Child's details")
                    Spacer()
                    SimpleCustomTextField(placeholder: "Name", text: $childDetails.name)
                    SimpleCustomTextField(placeholder: "Surname", text: $childDetails.surname)
                    Spacer()
                    Text("Please enter the date of birth below")
                        .font(Font.custom("Inter", size: 15))
                        .foregroundColor(.black)
                    CustomDateTextField(dateText: $childDetails.dateOfBirth)
                    Spacer()
                    Button(action: validateFields) {
                        CustomButton(
                            title: "Next step",
                            backgroundColor: Color(.buttonGreyLight),
                            textColor: .black
                        ).padding(.bottom, 60)
                    }
                    
                    // NavigationLink to next view
                    NavigationLink(destination: AddChildStepTwoView(childDetails: childDetails), isActive: $navigateToNextView) {
                        EmptyView()
                    }
                    
                    if showErrorMessage {
                        ErrorCustomText(title: errorMessage)
                    }
                    ProgressBar(progressMultiplier: 1)
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

    private func validateFields() {
        if childDetails.name.isEmpty || childDetails.surname.isEmpty || childDetails.dateOfBirth.isEmpty {
            errorMessage = "All fields must be completed!"
            showErrorMessage = true
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
            } else {
                errorMessage = "Date of birth cannot be in the future!"
                showErrorMessage = true
            }
        } else {
            errorMessage = "Please enter a valid date of birth!"
            showErrorMessage = true
        }
    }
}

#Preview {
    AddChildStepOneView()
}
